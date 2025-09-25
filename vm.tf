##########################################
# 1. Resource Group
##########################################
resource "azurerm_resource_group" "kalume" {
  name     = "kami-resources"
  location = "Canada Central" # Région Montréal
}

##########################################
# 2. Réseau virtuel
##########################################
resource "azurerm_virtual_network" "kami" {
  name                = "kami-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.kalume.location
  resource_group_name = azurerm_resource_group.kalume.name
}

##########################################
# 3. Subnet interne
##########################################
resource "azurerm_subnet" "kami" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.kalume.name
  virtual_network_name = azurerm_virtual_network.kami.name
  address_prefixes     = ["10.0.2.0/24"]
}

##########################################
# 4. Network Interface (sans IP publique → réseau interne uniquement)
##########################################
resource "azurerm_network_interface" "kami" {
  name                = "kami-nic"
  location            = azurerm_resource_group.kalume.location
  resource_group_name = azurerm_resource_group.kalume.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.kami.id
    private_ip_address_allocation = "Dynamic"
  }
}

##########################################
# 5. Clé SSH (bonne pratique)
##########################################
# ⚠️ La fonction file("~/.ssh/id_rsa.pub") donne une erreur si
# le chemin n’existe pas ou si Terraform n’a pas accès.
# Solution = créer une variable qui pointe vers ton fichier de clé SSH
# et utiliser file() sur ce chemin.
variable "ssh_public_key_path" {
  description = "Chemin vers la clé publique SSH"
  type        = string
  default     = "~/.ssh/id_rsa.pub" # change si ta clé est ailleurs
}

# Charger la clé depuis un fichier local
data "local_file" "ssh_key" {
  filename = pathexpand(var.ssh_public_key_path)
}

##########################################
# 6. Virtual Machine Debian
##########################################
resource "azurerm_linux_virtual_machine" "kami" {
  name                = "debian-vm"
  resource_group_name = azurerm_resource_group.kalume.name
  location            = azurerm_resource_group.kalume.location
  size                = "Standard_B1s" # VM pas chère pour tests
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.kami.id,
  ]

  # Clé SSH corrigée
  admin_ssh_key {
    username   = "adminuser"
    public_key = data.local_file.ssh_key.content
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Debian image officielle
  source_image_reference {
    publisher = "Debian"
    offer     = "debian-11"
    sku       = "11"
    version   = "latest"
  }
}
