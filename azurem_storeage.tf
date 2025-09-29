
/*
variable "location" {
  description = "Région Azure"
  type        = string
  default     = "Canada Central"
}
#Ce que c’est : La région Azure où seront créées toutes tes ressources (exemple : Montréal).

#Tu peux changer : La valeur par défaut "Canada Central" pour une autre région Azure comme "East US", "West Europe", etc.

variable "vnet_name" {
  description = "Nom du Virtual Network"
  type        = string
  default     = "kami"
}
#Ce que c’est : Le nom de ton réseau virtuel (VNet) dans Azure.

#Tu peux changer : Le nom "kami" par un autre nom qui te convient (exemple "my-vnet").

text
variable "subnet_name" {
  description = "Nom du subnet"
  type        = string
  default     = "kami"
}
#Ce que c’est : Le nom du subnet créé dans ton VNet.

#Tu peux changer : Le nom "kami" par ce que tu souhaites (exemple "internal-subnet").


variable "vnet_address_space" {
  description = "Liste des plages d'adresses CIDR pour le VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}
#Ce que c’est : La plage d’adresses IP utilisée par ton VNet. Ici, c’est une liste, donc tu pourrais ajouter plusieurs plages.

#Tu peux changer : Le CIDR "10.0.0.0/16" par d’autres plages compatibles avec ton réseau.


variable "subnet_address_prefixes" {
  description = "Liste des plages d'adresses CIDR pour le subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}
# Ce que c’est : La plage IP assignée à ton subnet à l’intérieur du VNet.

# Tu peux changer : Le CIDR "10.0.1.0/24" pour une autre plage plus appropriée à ta segmentation réseau.


variable "storage_account_names" {
  description = "Noms des 10 comptes de stockage"
  type        = list(string)
  default     = [
    "kami01", "kami02", "kami03", "kami04", "kami05",
    "kami06", "kami07", "kami08", "kami09", "kami10"
  ]
}
# Ce que c’est : La liste des noms que tu souhaites donner à tes dix comptes de stockage Azure.

# Tu peux changer : Ces noms pour refléter ta convention de nommage ou structure.

####Ressources

resource "azurerm_resource_group" "kami_rg" {
  name     = "kami-rg"
  location = var.location
}
# C’est le conteneur principal (resource group) qui regroupera tous tes objets Azure.

# Tu peux changer : Le nom "kami-rg" selon ta politique de nommage.

text
resource "azurerm_virtual_network" "kami_vnet" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = azurerm_resource_group.kami_rg.name
}
# Création du VNet en utilisant les variables pour nom, adresse IP, site.

# Change les variables pour personnaliser ce réseau virtuel.


resource "azurerm_subnet" "kami_subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.kami_rg.name
  virtual_network_name = azurerm_virtual_network.kami_vnet.name
  address_prefixes     = var.subnet_address_prefixes
}
# Création du subnet dans le VNet avec variables pour nom et plage d’adresses.

# À modifier via variables si tu veux un autre subnet.


resource "azurerm_storage_account" "kami_storage" {
  for_each                 = toset(var.storage_account_names)
  name                     = each.value
  resource_group_name      = azurerm_resource_group.kami_rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  min_tls_version          = "TLS1_2"

  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    virtual_network_subnet_ids = [azurerm_subnet.kami_subnet.id]
  }
}
*/


# Objectif de cet exercice Terraform
# L’objectif est de déployer automatiquement dans Azure un environnement complet comprenant:

# Un réseau virtuel Azure (Virtual Network / VNet) nommé "kami" :
# Ce réseau agit comme un espace isolé dans le cloud où tes ressources cloud (machines, comptes de stockage, applications, etc.) communiqueront entre elles de manière sécurisée.

# Un subnet (sous-réseau) nommé "kami" à l’intérieur du VNet :
# Le subnet segmente le VNet en parties plus petites pour mieux organiser et sécuriser les flux réseau. Par exemple, tu peux isoler des ressources dans différents subnets selon leur fonction.

# Dix comptes de stockage Azure (azurerm_storage_account) :
# Ce sont des espaces de stockage cloud pour données (fichiers, blobs, tables, queues…). Le fait d’en créer plusieurs te permet de gérer différentes charges de travail, environnements, ou projets sans chevauchement.

# Avec des contrôles réseaux configurés pour que seuls les services du subnet "kami" puissent accéder aux comptes de stockage.
# Ceci assure une couche de sécurité supplémentaire en limitant les accès à tes données.

# Pourquoi cet exercice est important
# Il te donne un modèle d’infrastructure automatisée, modulaire et scalable que tu peux reproduire à volonté ou modifier facilement via des variables (noms, plages IP, région, etc.).

# Il démontre les bonnes pratiques Azure et Terraform : séparation des responsabilités (RG, réseaux, stockage), restriction d’accès réseau, gestion propre du naming.

# Il te forme à l’orchestration et à la sécurisation des ressources cloud dans un environnement professionnel.



