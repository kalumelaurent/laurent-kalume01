
# VARIABLE - Liste des applications à créer

variable "apps" {
  description = "Liste des noms des applications Web à créer"
  type        = list(string)

  # Pourquoi ?
  # On définit ici les noms des applications sous forme de liste.
  # Cela permet d'éviter de dupliquer le code pour chaque application.
  # Si on ajoute ou retire un nom dans cette liste, Terraform créera ou supprimera automatiquement l'application correspondante.
  default     = ["inovocb-api", "riidoz-ui", "gamecb-core"]
}


# RESOURCE GROUP - Conteneur logique Azure

resource "azurerm_resource_group" "rg" {
  # Nom du Resource Group
  name     = "my-resource-group"

  # Région où seront déployées les ressources
  location = "Canada Central"

  # Pourquoi ?
  # Sur Azure, toutes les ressources doivent être dans un Resource Group.
  # Il sert de "boîte" logique pour organiser, gérer, et supprimer toutes les ressources d'un projet en une seule action.
}


# APP SERVICE PLAN - Machine partagée

resource "azurerm_service_plan" "plan" {
  # Nom du plan App Service
  name                = "asp-shared"

  # On réutilise la localisation et le resource group définis plus haut
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # OS utilisé par toutes les applis
  os_type             = "Linux"

  # Tier (niveau) du plan : B1 = Basic, peu coûteux
  sku_name            = "B1"

  # Pourquoi ?
  # Le plan définit les ressources physiques (CPU, RAM) utilisées par les apps.
  # Ici, un seul plan est partagé par toutes les applications → c’est économique
  # et plus simple à gérer (si on upgrade le plan, toutes les apps bénéficient de la nouvelle capacité).
}


# WEB APPS LINUX - Création dynamique

resource "azurerm_linux_web_app" "app" {
  # On boucle sur la liste des apps définies dans la variable.
  # Chaque nom de la liste devient une Web App distincte.
  for_each            = toset(var.apps)

  # Nom de l'application = valeur courante dans la boucle (inovocb-api, riidoz-ui, etc.)
  name                = each.value

  # Même localisation et même Resource Group que défini plus haut
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name

  # Chaque application Web est reliée au plan App Service partagé
  service_plan_id     = azurerm_service_plan.plan.id

  # Configuration du site Web
  site_config {
    application_stack {
      # On définit ici la stack technique utilisée.
      # Chaque application tourne avec Node.js en version 18 LTS (support long terme).
      node_version = "18-lts"
    }
  }

  # Pourquoi ?
  # Grâce au "for_each", on peut créer automatiquement plusieurs Web Apps
  # sans répéter du code. C’est flexible et scalable :
  # - On ajoute un nouveau nom dans la variable "apps" → une nouvelle app est déployée.
  # - On supprime un nom → l’app correspondante est détruite.
  # Cela rend le code propre, modulaire et facile à maintenir.
}
