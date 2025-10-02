
# VARIABLE QUI LISTE LES APPLICATIONS WEB     

variable "webapps" {
  type = list(object({
    name         = string   # le nom de l'application
    region       = string   # la région Azure où elle sera déployée
    sku_name     = string   # la taille/puissance du plan (ex: B1, P1v2, etc.)
    worker_count = number   # combien de machines (workers) vont travailler
  }))

  # Ici on a 4 applications différentes, chacune dans une région du monde
  default = [
    { name = "myapp-eu-001",    region = "westeurope",       sku_name = "B1",    worker_count = 1 },
    { name = "myapp-na-001",    region = "canadacentral",    sku_name = "P1v2",  worker_count = 2 },
    { name = "myapp-asia-001",  region = "japaneast",        sku_name = "S1",    worker_count = 3 },
    { name = "myapp-aus-001",   region = "australiaeast",    sku_name = "B2",    worker_count = 1 },
  ]
}


# En gros : c’est comme une liste d’élèves dans une classe. Chaque élève (app) a son prénom (name),... 
# sa ville (region), sa taille (sku_name) et le nombre de bras qu’il a pour travailler (worker_count).



# CRÉATION DES GROUPES DE RESSOURCES        

resource "azurerm_resource_group" "rg" {
  # On boucle sur chaque app et on crée un groupe dans sa région
  for_each = { for app in var.webapps : app.region => app }

  # Le nom du groupe commence par "rgk-" suivi du nom de l’app
  name     = "rg-${each.value.name}"

  # La région est celle définie pour l’app
  location = each.value.region
}

# En gros : chaque app a besoin d’une boîte pour ranger ses affaires → c’est le Resource Group.
# On crée donc une boîte (rg) dans la ville (region) de chaque appli.



# CRÉATION DES APP SERVICE PLANS            

resource "azurerm_service_plan" "plan" {
  # Un plan par région/app
  for_each            = { for app in var.webapps : app.region => app }

  # Nom du plan basé sur le nom de l’app
  name                = "sp-${each.value.name}"

  # On le met dans la même région et le même groupe que l’app
  location            = each.value.region
  resource_group_name = azurerm_resource_group.rg[each.key].name

  # Type de système d’exploitation → Linux
  os_type             = "Linux"

  # La puissance vient du YAML (sku_name et worker_count)
  sku_name            = each.value.sku_name
  worker_count        = each.value.worker_count
}


# En gros : le plan, c’est la machine sur laquelle ton appli va tourner.
#	sku_name = la taille de la machine (comme choisir un vélo petit, moyen ou gros .
#	worker_count = combien de vélos tu prends pour avancer plus vite 



# CRÉATION DES APPLICATIONS WEB LINUX         

resource "azurerm_linux_web_app" "app" {
  # Une Web App par région/app
  for_each            = { for app in var.webapps : app.region => app }

  # Nom de l’application
  name                = each.value.name

  # Région et groupe identiques à ceux définis pour l’app
  location            = each.value.region
  resource_group_name = azurerm_resource_group.rg[each.key].name

  # On attache l’app au plan qu’on vient de créer
  service_plan_id     = azurerm_service_plan.plan[each.key].id

  # Configuration de l’environnement (ici Node.js 18 LTS)
  site_config {
    application_stack {
      node_version = "18-lts"
    }
  }
}


# En gros : maintenant qu’on a la boîte (Resource Group) et la machine (App Service Plan), on installe l’application dessus.
# Ici toutes les applis utilisent Node.js 18 comme langage.

# 1 on lui donne une boîte (Resource Group) pour ranger ses affaires.
#	2.	On lui achète une machine (Service Plan) de la bonne taille.
#	3.	On installe son logiciel (Linux Web App) dessus.


