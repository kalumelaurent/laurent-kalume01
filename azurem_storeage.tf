
# Variables 
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

variable "vnet_address_space" {
  description = "Liste des plages d'adresses CIDR pour le VNet"
  type        = list(string)
  default     = ["10.0.0.0/16"]
}

variable "subnet_address_prefixes" {
  description = "Liste des plages d'adresses CIDR pour le subnet"
  type        = list(string)
  default     = ["10.0.1.0/24"]
}

variable "storage_account_names" {
  description = "Noms des 10 comptes de stockage"
  type        = list(string)
  default     = [
    "kami01",
    "kami02",
    "kami03",
    "kami04",
    "kami05",
    "kami06",
    "kami07",
    "kami08",
    "kami09",
    "kami10"
  ]
}

# Resources 

resource "azurerm_resource_group" "kami_rg" {
  name     = "kami-rg"
  location = var.location
}

resource "azurerm_virtual_network" "kami_vnet" {
  name                = var.vnet_name
  address_space       = var.vnet_address_space  # liste directement passée ici
  location            = var.location
  resource_group_name = azurerm_resource_group.kami_rg.name
}

resource "azurerm_subnet" "kami_subnet" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.kami_rg.name
  virtual_network_name = azurerm_virtual_network.kami_vnet.name
  address_prefixes     = var.subnet_address_prefixes  # liste directement passée ici
}

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
