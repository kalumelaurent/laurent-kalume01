

# CRÉATION D’UN RESOURCE GROUP (GROUPE DE RESSOURCES)

resource "azurerm_resource_group" "example" {
  name     = "example-resources"   # Nom du groupe de ressources Azure
  location = "West Europe"         # Région Azure où tout sera déployé
}



# CRÉATION D’UN CONTAINER REGISTRY (ACR)

# L’ACR (Azure Container Registry) sert à stocker les images Docker
# que ton cluster Kubernetes (AKS) pourra ensuite récupérer.
resource "azurerm_container_registry" "acr_joyce" {
  name                = "exampleregistry1234"            # Nom unique du registre (lettres minuscules + chiffres)
  resource_group_name = azurerm_resource_group.example.name  # Lien avec le groupe de ressources ci-dessus
  location            = azurerm_resource_group.example.location # Même région que le groupe de ressources
  sku                 = "Standard"                       # Type d’abonnement : Basic, Standard, ou Premium
  admin_enabled       = false                            # Désactivation du compte admin (plus sécurisé en production)
}



# CRÉATION D’UN CLUSTER KUBERNETES (AKS)

# Le cluster AKS est l’endroit où tes conteneurs seront exécutés.
resource "azurerm_kubernetes_cluster" "example" {
  name                = "example-aks1"                      # Nom du cluster
  location            = azurerm_resource_group.example.location  # Région
  resource_group_name = azurerm_resource_group.example.name       # Groupe de ressources parent
  dns_prefix          = "exampleaks1"                        # Préfixe DNS pour le cluster

  # Le pool de nœuds définit combien de machines virtuelles composent ton cluster
  default_node_pool {
    name       = "default"          # Nom du pool de nœuds
    node_count = 1                  # Nombre de nœuds (machines)
    vm_size    = "Standard_D2_v2"   # Type de machine virtuelle
  }

  # Identité gérée du cluster : permet à AKS d’interagir avec d’autres services Azure
  identity {
    type = "SystemAssigned"         # Azure gère automatiquement cette identité
  }

  tags = {
    Environment = "Production"      # Étiquette pour classer les ressources
  }
}



# ATTRIBUTION DE RÔLE : DONNER À AKS L’ACCÈS AU REGISTRE ACR

# Cette ressource permet à AKS de tirer (pull) les images depuis ton registre ACR.
resource "azurerm_role_assignment" "aks_acr_pull" {
  scope                = azurerm_container_registry.acr_joyce.id  # Cible du rôle : ton ACR
  role_definition_name = "AcrPull"                                # Rôle prédéfini pour autoriser le "pull"
  principal_id         = azurerm_kubernetes_cluster.example.kubelet_identity[0].object_id
  # L'identité du kubelet (le nœud Kubernetes) qui doit avoir accès à l’ACR
}



# SORTIES (OUTPUTS)

# Ces outputs affichent les infos utiles après l’exécution de Terraform.
output "acr_login_server" {
  value = azurerm_container_registry.acr_joyce.login_server   # L’URL de connexion du registre ACR
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.example.kube_config_raw  # Fichier de configuration du cluster (kubeconfig)
  sensitive = true   # Masqué pour éviter d’exposer des données sensibles

}



 # En résumé simple

#  L’objectif de cet exercice est de :
#	 créer un groupe de ressources pour ranger tout,
#	 créer un registre de conteneurs (ACR) pour stocker les images Docker,
#  créer un cluster Kubernetes (AKS) pour exécuter ces images,
#  donner à AKS la permission d’accéder à ACR,
#  et afficher les infos utiles à la fin (adresse du registre et configuration du cluster).

## En résumé : je  prépares un environnement dans Azure pour stocker et lancer des applications Docker.
