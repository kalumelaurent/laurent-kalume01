

# VARIABLES

/*
# Région Azure où les ressources seront créées
variable "location" {
  description = "Région Azure"
  type        = string
  default     = "Canada Central"
}

# Nom du groupe de ressources (un "dossier logique" qui regroupe les ressources Azure)
variable "resource_group_name" {
  description = "Nom du groupe de ressources"
  type        = string
  default     = "kami-rg"
}

# Nom du réseau virtuel (VNet = ton réseau privé dans Azure)
variable "vnet_name" {
  description = "Nom du Virtual Network"
  type        = string
  default     = "kami"
}

# Nom du sous-réseau (Subnet = une partie du VNet)
variable "subnet_name" {
  description = "Nom du subnet"
  type        = string
  default     = "kami"
}

# Plage d'adresses IP du VNet (ici : 65 000 adresses possibles)
variable "vnet_address_space" {
  description = "Plages CIDR du VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

# Plage IP attribuée au sous-réseau (ici : 256 adresses)
variable "subnet_address_prefixes" {
  description = "Plage CIDR du subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

# Liste des 10 comptes de stockage qui seront créés automatiquement
variable "storage_account_names" {
  description = "Noms pour les comptes de stockage"
  type        = list(string)
  default     = [
    "kami01", "kami02", "kami03", "kami04", "kami05",
    "kami06", "kami07", "kami08", "kami09", "kami10"
  ]
}

# Niveau de performance du stockage (Standard = pas cher, Premium = rapide)
variable "account_tier" {
  description = "Type de performance du compte de stockage (Standard ou Premium)"
  type        = string
  default     = "Standard"
}

# Type de réplication (LRS = local, GRS = multi-région)
variable "account_replication_type" {
  description = "Type de réplication du compte de stockage (LRS, GRS, etc.)"
  type        = string
  default     = "LRS"
}

# Type de compte (StorageV2 recommandé car moderne et complet)
variable "account_kind" {
  description = "Type du compte de stockage (StorageV2, BlobStorage, etc.)"
  type        = string
  default     = "StorageV2"
}

# Sécurité minimale des connexions (TLS1_2 conseillé)
variable "min_tls_version" {
  description = "Version minimale TLS à autoriser (TLS1_0, TLS1_1, TLS1_2, TLS1_3)"
  type        = string
  default     = "TLS1_2"
}

# Firewall stockage : comportement par défaut (Deny = tout bloquer sauf exceptions)
variable "storage_account_default_action" {
  description = "Comportement par défaut du firewall réseau du stockage ('Allow' ou 'Deny')"
  type        = string
  default     = "Deny"
}

# Quels services Azure peuvent bypasser le firewall (ex : AzureServices)
variable "storage_account_bypass" {
  description = "Liste des services Azure qui peuvent bypasser le firewall (ex: AzureServices, Logging, Metrics, None)"
  type        = list(string)
  default     = ["AzureServices"]
}


# RESSOURCES


# Création du groupe de ressources (notre "dossier" Azure)
resource "azurerm_resource_group" "kami_rg" {
  name     = var.resource_group_name
  location = var.location
}

# Création du réseau virtuel (VNet = autoroute privée dans Azure)
resource "azurerm_virtual_network" "kami_vnet" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space
  location            = var.location
  resource_group_name = azurerm_resource_group.kami_rg.name
}

# Création du sous-réseau (Subnet = une zone dans le VNet)
resource "azurerm_subnet" "kami_subnet" {
  name                 = var.subnet_name
  resource_group_name  = var.resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = var.subnet_address_prefixes
}

# Création de 10 comptes de stockage sécurisés
resource "azurerm_storage_account" "kami_storage" {
  # for_each = crée automatiquement un compte par nom dans la liste storage_account_names
  for_each                 = toset(var.storage_account_names)
  name                     = each.value
  resource_group_name      = azurerm_resource_group.kami_rg.name
  location                 = var.location
  account_tier             = var.account_tier
  account_replication_type = var.account_replication_type
  account_kind             = var.account_kind
  min_tls_version          = var.min_tls_version

  # Sécurité réseau : firewall appliqué au stockage
  network_rules {
    # Tout est bloqué par défaut
    default_action             = var.storage_account_default_action
    # Certains services Azure peuvent passer même avec le firewall
    bypass                     = var.storage_account_bypass
    # Autoriser uniquement les ressources de NOTRE subnet
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



