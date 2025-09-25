
#########################################################
# Variable pour définir le pays cible (Canada par défaut)
variable "country" {
  type    = string
  default = "canada"
}

# Variable SKU et OS type pour le plan App Service
variable "sku_name" {
  type    = string
  default = "P1v2"
}
variable "windows" {
  type    = string
  default = "Windows"
}

# Liste des items/apps à déployer
variable "items2" {
  type    = list(string)
  default = [
    "burger",
    "baseball",
    "jeans",
    "hollywood",
    "donut",
    "jazz",
    "applepie",
    "football",
    "route66",
    "hotdog"
  ]
}

# Resource group au Canada
#resource "azurerm_resource_group" "example" {
  name     = "rg-${var.country}-apps"
  location = "Canada Central"
}

# Service plan Windows au Canada
resource "azurerm_service_plan" "example" {
  name                = "plan-${var.country}-windows"
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  sku_name            = var.sku_name
  os_type             = var.windows
}

# Création des Windows Web Apps une par item, avec app_settings personnalisés
resource "azurerm_windows_web_app" "example" {
  for_each = toset(var.items)

  name                = "wa-${var.country}-${each.key}"
  resource_group_name = azurerm_resource_group.example.name
  location            = azurerm_resource_group.example.location
  service_plan_id     = azurerm_service_plan.example.id

  site_config {
    minimum_tls_version = "1.2"
  }

  # App settings personnalisés pour chaque app
  app_settings = {
    "COUNTRY" = var.country
    "ITEM"    = each.key
    "PREFIX"  = "wa-${var.country}"
  }
}
