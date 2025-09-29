###########################
# Variables pour personnalisation
###########################
variable "location" {
  description = "Région Azure"
  type        = string
  default     = "Canada Central"
}

variable "vnet_name" {
  description = "Nom du Virtual Network"
  type        = string
  default     = "kami"
}

variable "subnet_name" {
  description = "Nom du subnet"
  type        = string
  default     = "kami"
}

variable "storage_account_names" {
  description = "Liste des noms des 10 comptes de stockage"
  type        = list(string)
  default     = [
    "kamiaccount01",
    "kamiaccount02",
    "kamiaccount03",
    "kamiaccount04",
    "kamiaccount05",
    "kamiaccount06",
    "kamiaccount07",
    "kamiaccount08",
    "kamiaccount09",
    "kamiaccount10"
  ]
}

###########################
# Groupe de ressources
###########################
resource "azurerm_resource_group" "kami_rg" {
  name     = "kami-rg"
  location = var.location
}

###########################
# Création du réseau et subnet
###########################
resource "azurerm_virtual_network" "kami_vnet" {
  name                = var.vnet_name
  address_space       = ["10.0.0.0/16"]
  location            = var.location
  resource_group_name = azurerm_resource_group.kami_rg.name
}

resource "azurerm_subnet" "kami_subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.kami_rg.name
  virtual_network_name = azurerm_virtual_network.kami_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

###########################
# Création des comptes de stockage en boucle
###########################
resource "azurerm_storage_account" "kami_storage" {
  for_each                 = toset(var.storage_account_names)
  name                     = each.value
  resource_group_name      = azurerm_resource_group.kami_rg.name
  location                 = var.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  min_tls_version          = "TLS1_2"

  # Sécuriser le compte de stockage pour n'autoriser que le subnet kami l'accès
  network_rules {
    default_action             = "Deny"
    bypass                     = ["AzureServices"]
    virtual_network_subnet_ids = [azurerm_subnet.kami_subnet.id]
  }
}
