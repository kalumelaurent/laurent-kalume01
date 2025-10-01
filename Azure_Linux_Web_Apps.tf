# Variable contenant la liste des noms des applications
variable "apps" {
  description = "Liste des noms des applications Web à créer"
  type        = list(string)
  default     = ["inovocb-api", "riidoz-ui", "gamecb-core"]
}

# Groupe de ressources où seront créées les ressources
resource "azurerm_resource_group" "rg" {
  name     = "my-resource-group"
  location = "Canada Central"
}

# Création d'un seul plan App Service partagé pour toutes les applications
resource "azurerm_service_plan" "plan" {
  name                = "asp-shared"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"
  sku_name            = "B1"  # Tier Basic, économique
}

# Création dynamique de plusieurs Azure Linux Web Apps à partir de la variable "apps"
resource "azurerm_linux_web_app" "app" {
  for_each            = toset(var.apps)   # boucle sur la liste convertie en set
  name                = each.value         # nom de chaque application Web
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan.id  # toutes partagent le même service plan

  site_config {
    application_stack {
      node_version = "18-lts"   # runtime Node.js 18 Long Term Support pour chaque app
    }
  }
}

