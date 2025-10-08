


# Groupe de ressources

resource "azurerm_resource_group" "aks_rg" {
  name     = var.resource_group_name   #  Nom du groupe de ressources → tu peux changer dans variables.tf
  location = var.location              #  Région Azure à utiliser → modifiable (ex: "Canada Central", "France Central")
}

#  Le groupe de ressources agit comme un dossier logique
# pour ranger toutes tes ressources Azure : le cluster, le réseau, les disques, etc.


# Cluster Kubernetes (AKS)

resource "azurerm_kubernetes_cluster" "aks_cluster" {
  name                = var.cluster_name                   #  Nom du cluster AKS → modifiable dans variables.tf
  location            = azurerm_resource_group.aks_rg.location
  resource_group_name = azurerm_resource_group.aks_rg.name
  dns_prefix          = var.dns_prefix                     #  Préfixe DNS public → modifiable (doit être unique)

  #  Le dns_prefix sert à générer un nom DNS public du type :
  #     monprefix-hcp.canadacentral.azmk8s.io

 
  #  Pool de nœuds (machines virtuelles)
  
  default_node_pool {
    name       = var.node_pool_name    #  Nom du pool de nœuds → modifiable (ex: "default", "linuxpool")
    node_count = var.node_count        #  Nombre de machines (VMs) dans le cluster → modifiable
    vm_size    = var.vm_size           #  Type de machine virtuelle → modifiable selon tes besoins
  }


  #  Identité du cluster
 
  identity {
    type = "SystemAssigned"            #  Azure gère automatiquement les permissions du cluster
  }

  
  #  Tags (étiquettes de gestion)
 
  tags = {
    Environment = var.environment      #  Indique ton environnement → "Dev", "Test", "Production"
    Project     = var.project_name     #  Nom du projet → pour trier ou identifier facilement tes ressources
  }
}

#  Cette ressource crée le cluster Kubernetes complet.
# Tu peux ensuite te connecter à ton cluster AKS avec kubectl et le fichier kubeconfig.




# VARIABLES.TF — Personnalisation du cluster

#  je peux  modifies ces valeurs pour adapter mon cluster à ton projet


#  Région Azure
variable "location" {
  description = "Région où déployer les ressources Azure"
  type        = string
  default     = "Canada Central"   #Tu peux mettre "France Central", "East US", etc.
}

#  Nom du groupe de ressources
variable "resource_group_name" {
  description = "Nom du groupe de ressources Azure"
  type        = string
  default     = "rg-aks-demo"      #  Change pour identifier ton projet (ex: "rg-siteweb-prod")
}

#  Nom du cluster Kubernetes (AKS)
variable "cluster_name" {
  description = "Nom du cluster Kubernetes (AKS)"
  type        = string
  default     = "aks-cluster-demo" #  Nom visible dans le portail Azure → doit être unique
}

#  Préfixe DNS public
variable "dns_prefix" {
  description = "Préfixe DNS utilisé pour générer le FQDN public du cluster"
  type        = string
  default     = "aksdemo"          #  Change selon ton projet (ex: "monclusterdev")
}

#  Nom du pool de nœuds
variable "node_pool_name" {
  description = "Nom du pool de nœuds principal du cluster"
  type        = string
  default     = "default"          #  Tu peux changer pour "pool-linux" ou "prodpool"
}

#  Nombre de nœuds dans le cluster
variable "node_count" {
  description = "Nombre de nœuds (VMs) dans le cluster AKS"
  type        = number
  default     = 2                  #  Mets 1 pour test, 3 ou plus pour production
}

#  Taille des machines virtuelles utilisées
variable "vm_size" {
  description = "Taille des machines virtuelles utilisées dans le cluster"
  type        = string
  default     = "Standard_B2s"     #  Exemples :
                                   # - "Standard_B2s" → économique (tests)
                                   # - "Standard_D4s_v3" → performant (prod)
                                   # - "Standard_E2s_v3" → mémoire élevée
}

#  Environnement du cluster
variable "environment" {
  description = "Type d’environnement (Production, Development, etc.)"
  type        = string
  default     = "Development"      #  Change selon ton usage : "Production", "Test", "Dev"
}

#  Nom du projet
variable "project_name" {
  description = "Nom du projet ou de l’équipe associée à ce cluster"
  type        = string
  default     = "Terraform-AKS-Demo"  #  Exemples : "SiteWeb", "Ecommerce", "DevOpsInfra"
}




#  OUTPUTS.TF — Sorties d’informations après déploiement


# Certificat client pour authentification (gardé secret)
output "client_certificate" {
  value     = azurerm_kubernetes_cluster.aks_cluster.kube_config[0].client_certificate
  sensitive = true   #  Ne pas afficher dans la console pour éviter de divulguer des infos
}

#  Contenu complet du kubeconfig (pour kubectl)
output "kube_config" {
  value     = azurerm_kubernetes_cluster.aks_cluster.kube_config_raw
  sensitive = true   #  Protège le contenu dans les logs Terraform
}

# Nom du cluster créé (utile pour confirmation)
output "cluster_name" {
  value = azurerm_kubernetes_cluster.aks_cluster.name
}

# Région du déploiement
output "location" {
  value = azurerm_resource_group.aks_rg.location
}
