# Variables paramétrables SKU et OS
variable "sku_name" {
  type    = string
  default = "P1v2"
}
variable "windows" {
  type    = string
  default = "Windows"
}
variable "linux" {
  type    = string
  default = "Linux"
}

# Liste des apps Linux (Canada)
locals {
  canada_linux_apps = [
    "mapleleaf", "hockey", "poutine", "mountie", "niagara",
    "timhortons", "beavertail", "loonie", "canoe", "igloo"
  ]
}

# Liste des apps Windows (USA)
locals {
  usa_windows_apps = [
    "burger", "baseball", "jeans", "hollywood", "donut",
    "jazz", "applepie", "football", "route66", "hotdog"
  ]
}

# Resource group Canada (Linux)
resource "azurerm_resource_group" "canada" {
  name     = "rg-linux-canada"
  location = "Canada Central"
}

# Resource group USA (Windows)
resource "azurerm_resource_group" "usa" {
  name     = "rg-windows-usa"
  location = "East US"
}

# Service plan Linux Canada
resource "azurerm_service_plan" "canada_linux" {
  name                = "plan-linux-canada"
  resource_group_name = azurerm_resource_group.canada.name
  location            = azurerm_resource_group.canada.location
  sku_name            = var.sku_name
  os_type             = var.linux
}

# Service plan Windows USA
resource "azurerm_service_plan" "usa_windows" {
  name                = "plan-windows-usa"
  resource_group_name = azurerm_resource_group.usa.name
  location            = azurerm_resource_group.usa.location
  sku_name            = var.sku_name
  os_type             = var.windows
}

# Linux Web Apps Canada
resource "azurerm_linux_web_app" "canada" {
  for_each            = toset(local.canada_linux_apps)

  name                = "wa-canada-${each.key}"
  resource_group_name = azurerm_resource_group.canada.name
  location            = azurerm_resource_group.canada.location
  service_plan_id     = azurerm_service_plan.canada_linux.id

  site_config {
    minimum_tls_version = "1.2"
  }
}

# Windows Web Apps USA
resource "azurerm_windows_web_app" "usa" {
  for_each            = toset(local.usa_windows_apps)

  name                = "wa-usa-${each.key}"
  resource_group_name = azurerm_resource_group.usa.name
  location            = azurerm_resource_group.usa.location

  # CORRECTION de l'erreur classique : bien référencer l'ID du service plan spécifique
  service_plan_id     = azurerm_service_plan.usa_windows.id    

  site_config {
    minimum_tls_version = "1.2"
  }
}
