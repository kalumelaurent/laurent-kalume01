# Groupe de ressources Montréal
resource "azurerm_resource_group" "kalume" {
  name     = "kami-resources"
  location = "Canada Central"  # correction région
}

# Virtual Network interne
resource "azurerm_virtual_network" "kami" {
  name                = "kami-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.kalume.location
  resource_group_name = azurerm_resource_group.kalume.name
}

# Subnet interne
resource "azurerm_subnet" "kami" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.kalume.name
  virtual_network_name = azurerm_virtual_network.kami.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Network Interface sur subnet interne
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

# Clé SSH passée comme variable string, pas via file() ou local_file
variable "admin_ssh_public_key" {
  type        = string
  description = "Clé publique SSH, à fournir comme string, pas fichier"
}

# VM Linux Debian sur réseau interne
resource "azurerm_linux_virtual_machine" "kami" {
  name                  = "debian-vm-montreal"
  resource_group_name   = azurerm_resource_group.kalume.name
  location              = azurerm_resource_group.kalume.location
  size                  = "Standard_F2"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.kami.id]

  admin_ssh_key {
    username   = "adminuser"
    public_key = var.admin_ssh_public_key
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Debian"
    offer     = "debian-11"
    sku       = "11"
    version   = "latest"
  }
}
