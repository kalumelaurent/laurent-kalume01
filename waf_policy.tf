/*
# 1. Groupe de ressources pour centraliser toutes les ressources
resource "azurerm_resource_group" "rg" {
  name     = "waf-demo-rg"
  location = "Canada Central"
}

# 2. VNet pour réseaux internes (obligatoire pour Application Gateway)
resource "azurerm_virtual_network" "vnet" {
  name                = "demo-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
}

# 3. Subnet dédié Application Gateway
resource "azurerm_subnet" "appgw_subnet" {
  name                 = "appgw-subnet"
  resource_group_name  = azurerm_resource_group.rg.name
  virtual_network_name = azurerm_virtual_network.vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# 4. IP publique pour exposer le Gateway sur Internet
resource "azurerm_public_ip" "gw_ip" {
  name                = "waf-gw-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# 5. Boucle pour créer dynamiquement 5 WAF policies différentes
locals {
  waf_policy_names = [
    "demo-wafpolicy1",
    "demo-wafpolicy2",
    "demo-wafpolicy3",
    "demo-wafpolicy4",
    "demo-wafpolicy5"
  ]
}

resource "azurerm_web_application_firewall_policy" "policy" {
  for_each           = toset(local.waf_policy_names)
  name               = each.value
  resource_group_name = azurerm_resource_group.rg.name
  location           = azurerm_resource_group.rg.location

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
  # Exemple de règle custom simple (identique pour chaque policy ici, modifiable selon tes besoins)
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
*/


# - La WAF Policy sécurise le trafic web contre les vulnérabilités classiques (OWASP) et personnalisées (custom_rules).
# - Son association au gateway (application gateway) permet de filtrer les attaques avant d'atteindre la Web App.
# - Le trafic client arrive au gateway, le WAF l'analyse selon la politique définie puis le redirige vers la Web App si le trafic est autorisé.
# - Impossible d'assigner une WAF Policy directement à un App Service : l'architecture Azure impose l'usage du gateway comme reverse proxy sécurisé.
# - Ce design facilite la gestion centralisée des règles sécurité, leur réutilisation et leur évolution sans toucher à la Web App directement.
# - La politique WAF peut être enrichie (custom rules, exclusions, mode detection...), rendant la solution robuste et flexible.
