# 1. Création du groupe de ressources
resource "azurerm_resource_group" "rg" {
  name     = "waf-demo-rg"
  location = "Canada Central"
}

# 2. Création d'un VNet nécessaire à l'Application Gateway (obligatoire sur Azure)
resource "azurerm_virtual_network" "vnet" {
  name                = "demo-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# 3. Subnet dédié à l'Application Gateway
resource "azurerm_subnet" "appgw_subnet" {
  name                 = "appgw-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"] # Ne pas partager ce subnet avec d'autres ressources Azure !
}

# 4. IP publique pour exposer le Application Gateway sur Internet
resource "azurerm_public_ip" "gw_ip" {
  name                = "waf-gw-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# 5. Définition d'une WAF Policy centralisée pour l'Application Gateway
resource "azurerm_web_application_firewall_policy" "policy" {
  name                = "demo-waf-policy"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  policy_settings {
    enabled = true
    mode    = "Prevention"
  }
  managed_rules {
    managed_rule_set {
      type    = "OWASP"
      version = "3.2"
    }
  }
  custom_rules {
    name      = "BlockIPs"
    priority  = 1
    rule_type = "MatchRule"
    action    = "Block"
    match_conditions {
      match_variables { variable_name = "RemoteAddr" }
      operator     = "IPMatch"
      match_values = ["1.2.3.4"]
    }
  }
}

# 6. Application Gateway avec association WAF POLICY et référence automatique au subnet
resource "azurerm_application_gateway" "gw" {
  name                = "demo-waf-gw"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gw-ip-config"
    subnet_id = azurerm_subnet.appgw_subnet.id  # Correction: plus besoin de fournir ID "à la main"
  }

  frontend_port {
    name = "frontendPort"
    port = 80
  }
  frontend_ip_configuration {
    name                 = "frontendIP"
    public_ip_address_id = azurerm_public_ip.gw_ip.id
  }
  backend_address_pool {
    name  = "demo-backend"
    fqdns = ["<webapp-name>.azurewebsites.net"] # à remplacer par ta Web App cible
  }
  backend_http_settings {
    name                              = "settings"
    port                              = 80
    protocol                          = "Http"
    cookie_based_affinity              = "Disabled"
    pick_host_name_from_backend_address = true
  }
  http_listener {
    name                           = "listener"
    frontend_ip_configuration_name = "frontendIP"
    frontend_port_name             = "frontendPort"
    protocol                       = "Http"
  }
  request_routing_rule {
    name                       = "rule1"
    rule_type                  = "Basic"
    http_listener_name         = "listener"
    backend_address_pool_name  = "demo-backend"
    backend_http_settings_name = "settings"
  }
  firewall_policy_id = azurerm_web_application_firewall_policy.policy.id
}
