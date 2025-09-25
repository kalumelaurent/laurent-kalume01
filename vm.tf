

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
# 4. Network Interface (pas d’IP publique)
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
# 5. Clé SSH (bonne pratique corrigée)
##########################################

# Variable pour pointer vers le chemin du fichier clé publique
# ⚠️ Remplace par ton chemin absolu si "~" ne marche pas
variable "ssh_public_key_path" {
  description = "Chemin vers la clé publique SSH"
  type        = string
  # Exemple Linux/Mac : "/home/kalume/.ssh/id_rsa.pub"
  # Exemple Windows   : "C:/Users/kalume/.ssh/id_rsa.pub"
  default     = "/home/kalume/.ssh/id_rsa.pub"
}

# Charger la clé publique depuis le fichier local
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
  size                = "Standard_B1s" # VM économique pour tests
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.kami.id,
  ]

  # Utilisation de la clé SSH corrigée
  admin_ssh_key {
    username   = "adminuser"
    public_key = data.local_file.ssh_key.content
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Image officielle Debian 11
  source_image_reference {
    publisher = "Debian"
    offer     = "debian-11"
    sku       = "11"
    version   = "latest"
  }
}

##########################################
# 7. Output (affiche l’adresse IP privée de la VM)
##########################################
output "private_ip_address" {
  description = "Adresse IP privée de la VM Debian"
  value       = azurerm_network_interface.kami.ip_configuration[0].private_ip_address
}
