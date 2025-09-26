# 1. Le groupe de ressources place toutes les ressources dans un même conteneur logique (meilleure gestion et organisation Azure)
resource "azurerm_resource_group" " {
  name     = "waf-demo-rg"
  location = "Canada Central"
}

# 2. Création de la WAF Policy pour centraliser la configuration de sécurité applicative
resource "azurerm_web_application_firewall_policy" "waf_policy" {
  name                = "demo-waf-policy"
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location

  policy_settings {
    enabled = true                 # Active la WAF sur le gateway
    mode    = "Prevention"         # Mode "Prevention" bloque les attaques au lieu de simplement les détecter ("Detection")
  }

  managed_rules {
    managed_rule_set {
      type    = "OWASP"            # Ensemble de règles OWASP, reconnu pour la protection des vulnérabilités web courantes
      version = "3.2"
    }
  }

  # Exemple d'une règle personnalisée pour bloquer une IP ou signer d'autres comportements inhabituels (optionnel)
  custom_rules {
    name      = "BlockBadIP"
    priority  = 1
    rule_type = "MatchRule"
    action    = "Block"
    match_conditions {
      match_variables {
        variable_name = "RemoteAddr" # Variable analysée (ici l’adresse IP distante)
      }
      operator     = "IPMatch"       # Type de correspondance
      match_values = ["1.2.3.4"]     # Adresse IP à bloquer
    }
  }
}

# 3. Le WAF Policy n'agit que via un reverse-proxy compatible : Application Gateway
# On crée un public IP pour exposer ce gateway (il reçoit tout le trafic avant la web app)
resource "azurerm_public_ip" "gw_ip" {
  name                = "waf-gateway-ip"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  allocation_method   = "Static"
  sku                 = "Standard"
}

# 4. Application Gateway : reverse proxy devant la webapp, point d'entrée web et intégration du WAF
resource "azurerm_application_gateway" "waf_gw" {
  name                = "waf-gateway"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  sku {
    name     = "WAF_v2"
    tier     = "WAF_v2"
    capacity = 2
  }

  gateway_ip_configuration {
    name      = "gw-ip-config"
    subnet_id = "<ID_SUBNET>"   # À remplacer par ton subnet dans un VNet existant
  }
  frontend_port {
    name = "frontendPort"
    port = 80
  }
  frontend_ip_configuration {
    name                 = "frontendIP"
    public_ip_address_id = azurerm_public_ip.gw_ip.id
  }
  # backend pool = webapp Azure FQDN, permet de relier le trafic proxy à la webapp cible
  backend_address_pool {
    name  = "app-backend-pool"
    fqdns = ["<web-app-name>.azurewebsites.net"] # à personnaliser avec ta webapp
  }
  backend_http_settings {
    name                             = "settings"
    cookie_based_affinity             = "Disabled"
    port                             = 80
    protocol                         = "Http"
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
    backend_address_pool_name  = "app-backend-pool"
    backend_http_settings_name = "settings"
  }
  firewall_policy_id = azurerm_web_application_firewall_policy.waf_policy.id
  force_firewall_policy_association = true
}

# ---------------------------------------------------------------------------------------
# Pourquoi ce design ?
# ---------------------------------------------------------------------------------------
# - Un WAF Policy permet de définir et centraliser toutes les règles de sécurité applicative.
# - Seul un reverse proxy comme Application Gateway Azure peut intégrer et appliquer ces règles en amont d’une web app.
# - Application Gateway reçoit le trafic web, applique la WAF Policy, puis achemine le trafic vers la web app. Tout le filtrage et blocage s'effectue avant que la webapp soit touchée.
# - Les custom_rules permettent de réagir à des cas métier ou menaces spécifiques (IPs, pays, regex...).
# - Mode Prevention active la protection directe, Mode Detection sert pour les tests ou audits sécurité.
# - Il est impossible de relier directement une WAF Policy à un App Service sans passer par le reverse proxy Application Gateway.
