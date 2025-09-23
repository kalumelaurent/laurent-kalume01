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






# Groupe de ressources unique (on choisit une région principales
#Déployer plusieurs instances d’une Web App Windows dans différentes régions Azure (5 pays différents, 5 régions)
# Groupe de ressources principal (dans une région, peut être ajusté)
resource "azurerm_resource_group" "example" {
  name     = "example-resources"
  location = "West Europe"
}

# Création d'un App Service Plan Windows par région avec utilisation des variables
resource "azurerm_service_plan" "example" {
  for_each = toset(var.locations)

  name                = "example-plan-${replace(each.key, " ", "-")}"
  resource_group_name = azurerm_resource_group.example.name
  location            = each.key
  sku_name            = var.sku_name       # Utilise la variable SKU du service plan
  os_type             = var.windows        # Utilise la variable OS type ("Windows")
}

# Création de la Web App Windows dans chaque région avec bon mapping du service_plan_id
resource "azurerm_windows_web_app" "example" {
  for_each = toset(var.locations)

  name                = "example-webapp-${replace(each.key, " ", "-")}"
  resource_group_name = azurerm_resource_group.example.name
  location            = each.key
  service_plan_id     = azurerm_service_plan.example[each.key].id   # Correction de l'erreur : sélectionne le bon service plan

  site_config {
    minimum_tls_version = "1.2"
  }
}
