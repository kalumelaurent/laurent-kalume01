# Liste des noms d'applications Windows à déployer aux USA
variable "usa_items" {
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

resource "azurerm_resource_group" "usa_rg" {
  name     = "wa-usa-rg"
  location = "East US"

  tags = {
    environment = "dev"
    project     = "wa-usa"
  }
}

resource "azurerm_service_plan" "usa_windows_plan" {
  name                = "wa-usa-windows-plan"
  location            = azurerm_resource_group.usa_rg.location
  resource_group_name = azurerm_resource_group.usa_rg.name
  os_type             = "Windows"
  sku_name            = "P1v2"

  tags = {
    environment = "dev"
    project     = "wa-usa"
  }
}

# Convertir la liste en map pour for_each
locals {
  usa_map = {for item in var.usa_items : item => item}
}

resource "azurerm_windows_web_app" "usa_apps" {
  for_each            = local.usa_map

  name                = "wa-usa-${each.key}"
  location            = azurerm_service_plan.usa_windows_plan.location
  resource_group_name = azurerm_resource_group.usa_rg.name
  service_plan_id     = azurerm_service_plan.usa_windows_plan.id

  site_config {
    minimum_tls_version = "1.2"
    always_on           = false
  }

  app_settings = {
    COUNTRY = "usa"
    ITEM    = each.key
    PREFIX  = "wa-usa"
  }

  tags = {
    environment = "dev"
    project     = "wa-usa"
    item        = each.key
  }
}

output "windows_webapp_names" {
  value = [for app in azurerm_windows_web_app.usa_apps : app.name]
}

