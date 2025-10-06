/*

resource "azurerm_resource_group" "example" {
  name     = "example-resources"         # Nom logique du groupe de ressources
  location = "West Europe"               # Choisis la région Azure qui t'arrange
}

resource "azurerm_kubernetes_cluster" "example" {
  name                = "example-aks1"                  # Nom unique du cluster AKS
  location            = azurerm_resource_group.example.location
  resource_group_name = azurerm_resource_group.example.name
  dns_prefix          = "exampleaks1"                   # Utilisé pour le FQDN public

  default_node_pool {
    name       = "default"           # Nom du pool principal
    node_count = 1                    # Nombre minimum de nœuds (VMs)
    vm_size    = "Standard_D2_v2"    # Taille/type de VM désirée
  }

  identity {
    type = "SystemAssigned"           # Pour gérer les accès Azure facilement (sécurité)
  }

  tags = {
    Environment = "Production"        # Bon réflexe : taguer pour trier, auditer, automatiser
  }
}


output "client_certificate" {
  value     = azurerm_kubernetes_cluster.example.kube_config[0].client_certificate
  sensitive = true   # Garde secret dans Terraform CLI pour plus de sécurité
}

output "kube_config" {
  value     = azurerm_kubernetes_cluster.example.kube_config_raw
  sensitive = true   # Empêche l’exposition accidentelle dans les logs
}

*/
