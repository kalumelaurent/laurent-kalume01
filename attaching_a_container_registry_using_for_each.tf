

# CREATION DU RESOURCE GROUP UNIQUE (Kami)

# Un Resource Group est comme un dossier dans Azure.
# Il regroupe toutes les ressources liées à ton projet.
resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name    # Nom du groupe défini dans variables.tf (ex: "Kami")
  location = var.locationcluter         # Région Azure (ex: Canada Central)
}



#  CREATION DES REGISTRES DE CONTENEURS (ACR)

# Un ACR (Azure Container Registry) sert à stocker les images Docker.
# Grâce au for_each, Terraform va créer plusieurs ACR à partir de la liste var.acr_names.
resource "azurerm_container_registry" "acr" {
  for_each            = toset(var.acr_names)              # Convertit la liste en ensemble unique
  name                = each.key                          # Nom de chaque ACR (ex: mcitacr1, mcitacr2…)
  resource_group_name = azurerm_resource_group.rg.name    # Tous les ACR sont placés dans le même Resource Group
  location            = azurerm_resource_group.rg.location
  sku                 = var.acr_sku                       # Type de performance (Basic, Standard, Premium)
  admin_enabled       = true                              # Active le compte admin (utile pour test/démo)

  tags = {
    Project = var.project_name
    Env     = var.environment
  }
}



#  CREATION DES CLUSTERS KUBERNETES (AKS)

# Un cluster Kubernetes (AKS) permet d’exécuter plusieurs conteneurs Docker.
# On en crée plusieurs à partir de la liste var.cluster_names.
resource "azurerm_kubernetes_cluster" "aks" {
  for_each            = toset(var.cluster_names)          # Crée un cluster AKS pour chaque nom
  name                = each.key                          # Nom du cluster (ex: mcit-aks-1)
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${each.key}-dns"                 # Préfixe DNS unique pour le cluster

  #  Configuration du pool de nœuds (les serveurs qui exécuteront les conteneurs)
  default_node_pool {
    name       = "systempool"                             # Nom du pool
    node_count = var.node_count                           # Nombre de nœuds (serveurs)
    vm_size    = var.vm_size                              # Taille de chaque machine virtuelle
  }

  #  Identité gérée : permet au cluster d’interagir avec d’autres services Azure
  identity {
    type = "SystemAssigned"                               # Azure gère automatiquement cette identité
  }

  role_based_access_control_enabled = true                # Active la gestion des rôles (RBAC)

  tags = {
    Project = var.project_name
    Env     = var.environment
  }

  depends_on = [azurerm_container_registry.acr]           # Attendre la création des ACR avant les clusters
}


#  ATTRIBUTION DES PERMISSIONS ENTRE AKS ET ACR
# La connexion se fait ici, dans la ressource azurerm_role_assignment,
# parce que c’est là qu’on autorise le cluster AKS à accéder au registre ACR.
# Sans cette partie, Kubernetes ne pourrait pas télécharger ni exécuter les applications Docker.

# Objectif : donner à chaque cluster AKS la permission de "tirer" (pull) les images Docker
# depuis le premier ACR créé (ACR principal).
resource "azurerm_role_assignment" "acr_pull" {
  for_each             = toset(var.cluster_names)          # Une permission par cluster
  principal_id         = azurerm_kubernetes_cluster.aks[each.key].kubelet_identity[0].object_id
  # Identité du kubelet (le "robot" Kubernetes) du cluster
  
  role_definition_name = "AcrPull"                        # Rôle Azure permettant de lire les images dans ACR
  scope                = element(values(azurerm_container_registry.acr), 0).id 
  # On prend le premier ACR de la liste pour lui donner la permission
}



#  VARIABLES.TF — PARAMÈTRES DE CONFIGURATION

# Ces variables permettent de personnaliser le déploiement facilement sans changer le code.

variable "locationcluter" {
  type        = string
  default     = "Canada Central"
}

variable "resource_group_name" {
  type        = string
  default     = "Kami"
}

variable "acr_names" {
  type    = list(string)
  default = ["mcitacr1", "mcitacr2", "mcitacr3"]
}

variable "acr_sku" {
  type        = string
  default     = "Standard"
}

variable "cluster_names" {
  type    = list(string)
  default = ["mcit-aks-1", "mcit-aks-2", "mcit-aks-3", "mcit-aks-4", "mcit-aks-5"]
}

variable "vm_size" {
  type        = string
  default     = "Standard_B2s"
}

variable "node_count" {
  type        = number
  default     = 1
}

variable "project_name" {
  type        = string
  default     = "Kami-Multi-AKS-ACR"
}

variable "environment" {
  type        = string
  default     = "Development"
}



#  OUTPUTS.TF — AFFICHAGE DES RÉSULTATS

# À la fin de l’exécution de Terraform, ces outputs montrent les infos utiles du déploiement.

output "acr_list" {
  value = [for k, v in azurerm_container_registry.acr : v.login_server]
  # Liste des adresses de connexion de tous les ACR créés
}

output "aks_list" {
  value = [for k, v in azurerm_kubernetes_cluster.aks : v.name]
  # Liste des noms de tous les clusters Kubernetes créés
}

output "resource_group_name" {
  value = azurerm_resource_group.rg.name
  # Nom du Resource Group (Kami)
}
