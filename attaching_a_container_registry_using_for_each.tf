

#  Resource Group unique : Kami

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group_name    #  Nom défini dans variables.tf (Kami)
  location = var.location
}


#  Azure Container Registries (ACR)

# Crée plusieurs ACR à partir d'une liste var.acr_names
resource "azurerm_container_registry" "acr" {
  for_each            = toset(var.acr_names)
  name                = each.key                     # ex: mcitacr1, mcitacr2
  resource_group_name = azurerm_resource_group.rg.name
  location            = azurerm_resource_group.rg.location
  sku                 = var.acr_sku
  admin_enabled       = true

  tags = {
    Project = var.project_name
    Env     = var.environment
  }
}


# Azure Kubernetes Clusters (AKS)

# Crée plusieurs clusters à partir de la liste var.cluster_names
# Chaque cluster pourra se connecter à l’un des ACR
resource "azurerm_kubernetes_cluster" "aks" {
  for_each            = toset(var.cluster_names)
  name                = each.key                     # ex: mcit-aks-1, mcit-aks-2
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "${each.key}-dns"

  default_node_pool {
    name       = "systempool"
    node_count = var.node_count
    vm_size    = var.vm_size
  }

  identity {
    type = "SystemAssigned"
  }

  role_based_access_control_enabled = true

  tags = {
    Project = var.project_name
    Env     = var.environment
  }

  depends_on = [azurerm_container_registry.acr]
}


#  Attribution des permissions ACR  AKS

#  Donne la permission "AcrPull" pour que chaque cluster puisse tirer des images
#  Associe chaque cluster AKS au premier ACR créé (par exemple le ACR principal)
resource "azurerm_role_assignment" "acr_pull" {
  for_each             = toset(var.cluster_names)
  principal_id         = azurerm_kubernetes_cluster.aks[each.key].kubelet_identity[0].object_id
  role_definition_name = "AcrPull"
  scope                = element(values(azurerm_container_registry.acr), 0).id # 💡 Premier ACR de la liste
}






# VARIABLES.TF — Personnalisation avec for_each


#  Région Azure
variable "location" {
  type        = string
  default     = "Canada Central"
}

#  Resource Group unique
variable "resource_group_name" {
  type        = string
  default     = "Kami"
}

#  Liste des ACR à créer
variable "acr_names" {
  type    = list(string)
  default = ["mcitacr1", "mcitacr2", "mcitacr3"]
}

# ⚙️ Type de ACR
variable "acr_sku" {
  type        = string
  default     = "Standard"
}

#  Liste des clusters AKS
variable "cluster_names" {
  type    = list(string)
  default = ["mcit-aks-1", "mcit-aks-2", "mcit-aks-3", "mcit-aks-4", "mcit-aks-5"]
}

# 💻 Taille et nombre de nœuds
variable "vm_size" {
  type        = string
  default     = "Standard_B2s"
}

variable "node_count" {
  type        = number
  default     = 1
}

# Tags
variable "project_name" {
  type        = string
  default     = "Kami-Multi-AKS-ACR"
}

variable "environment" {
  type        = string
  default     = "Development"
}



# OUTPUTS.TF — Résumé du déploiement


#  Liste des ACR créés
output "acr_list" {
  value = [for k, v in azurerm_container_registry.acr : v.login_server]
}

# Liste des clusters AKS créés
output "aks_list" {
  value = [for k, v in azurerm_kubernetes_cluster.aks : v.name]
}

# 📂 Resource Group
output "resource_group_name" {
  value = azurerm_resource_group.rg.name
}


