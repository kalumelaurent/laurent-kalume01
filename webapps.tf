

# Variable pour définir le pays cible
# On crée une variable pour savoir dans quel pays on veut déployer nos ressources.
# Par défaut, c'est le Canada.
variable "country" {
  type    = string
  default = "canada"
}


# Variable SKU et OS type pour le plan App Service
# SKU = le "niveau" de ton plan App Service (combien de puissance tu veux)
# OS type = Windows ou Linux
variable "sku_name" {
  type    = string
  default = "P1v2"
}

variable "windows" {
  type    = string
  default = "Windows"
}


# Liste des items/apps à déployer
# Ici on fait une liste de noms d'applications à créer.
# Chaque élément de la liste sera transformé en une Web App.
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


# Création du Resource Group au Canada
# Le Resource Group est comme un "dossier" où on range toutes nos ressources Azure.
resource "azurerm_resource_group" "example" {
  name     = "rg-${var.country}-apps"   # Nom dynamique selon le pays
  location = "Canada Central"           # Région géographique
}


# Création du Service Plan Windows
# Le Service Plan, c'est la "puissance" que tes apps vont utiliser (CPU, RAM, etc.)
resource "azurerm_service_plan" "example" {
  name                = "plan-${var.country}-windows"        # Nom dynamique
  location            = azurerm_resource_group.example.location  # Même région que le RG
  resource_group_name = azurerm_resource_group.example.name     # On met ce plan dans notre RG
  sku_name            = var.sku_name                           # Niveau/Puissance
  os_type             = var.windows                            # Windows ou Linux
}


# Création des Windows Web Apps
# On crée une app pour **chaque élément** de notre liste `items2`
resource "azurerm_windows_web_app" "example" {
  for_each = toset(var.items2)     #  Pour chaque item dans la liste, Terraform crée une app

  name                = "wa-${var.country}-${each.key}"       # Nom unique pour chaque app
  resource_group_name = azurerm_resource_group.example.name   # On met l'app dans le RG
  location            = azurerm_resource_group.example.location  # Même région
  service_plan_id     = azurerm_service_plan.example.id      # On lie l'app au service plan


  #  Configuration TLS minimum
  
  site_config {
    minimum_tls_version = "1.2"    # Sécurité : TLS 1.2 minimum pour le site
  }

  
  # Paramètres personnalisés pour chaque app
  app_settings = {
    "COUNTRY" = var.country                  # On garde le pays
    "ITEM"    = each.key                     # On garde le nom de l'app (burger, baseball...)
    "PREFIX"  = "wa-${var.country}"         # Un petit préfixe pour identifier l'app
  }
}


# En résumé :
# Cet exercice montre comment automatiser le déploiement de plusieurs applications Windows sur Azure, tout en gardant le code réutilisable et dynamique grâce aux variables et for_each
