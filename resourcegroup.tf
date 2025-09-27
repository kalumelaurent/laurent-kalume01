resource "azurerm_resource_group" "terraformmay022025" {
  name     = "mcit_resource_group_may0220lk"
  location = "canadacentral"
}
resource "azurerm_resource_group" "terraformseptember" {
  name     = "mcit_resource_group_sep0920lk"
  location = "canadacentral"
}





# En résumé, cet exercice vous équipe pour gérer efficacement vos apps cloud via Terraform, assurant contrôle, rapidité, et rigueur dans vos déploiements Azure
# Création du groupe de ressources Azure

/*variable "location" {
  default = "CanadaEast"
}

resource "azurerm_resource_group" "example" {
  name     = "rg-demo"
  location = var.location  # réutilisation de la variable
}



resource "azurerm_resource_group" "rg" {
  name     = "${var.project_name}-rg"  # Nom unique basé sur le nom du projet
  location = var.location               # Région Azure
}

# Création du plan de service Linux pour héberger l'application web
resource "azurerm_service_plan" "plan" {
  name                = "${var.project_name}-plan"       # Nom unique du plan
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  os_type             = "Linux"                          # Spécifie le système d'exploitation Linux
  sku_name            = var.plan_sku_name                # SKU (B1, P1v3, etc.)
}

# Création de l'application web Linux
resource "azurerm_linux_web_app" "app" {
  name                = "${var.project_name}-app"        # Nom de l'application
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  service_plan_id     = azurerm_service_plan.plan.id     # Lien vers le plan de service Linux

  https_only = true                                       # Force HTTPS

  site_config {
    application_stack {
      node_version = "20-lts"                             # Runtime Node.js (modifiable selon besoin)
      # python_version = "3.12"                           # Exemple d'autre runtime possible
      # dotnet_version = "8.0"
    }
    always_on = true                                      # Maintient l'application toujours active
  }

  # Paramètres d'application spécifiques pour le fonctionnement et le déploiement
  app_settings = {
    WEBSITES_ENABLE_APP_SERVICE_STORAGE = "false"
    SCM_DO_BUILD_DURING_DEPLOYMENT      = "true"
  }
}

# Ressource pour écrire le contenu dans un fichier texte
resource "local_file" "top_5_list" {
  content  = local.top_lists_text
  filename = "top_5_lists.txt"
}
/*

