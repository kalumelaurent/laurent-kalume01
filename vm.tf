resource "azurerm_resource_group" "kalume" {
  name     = "kami-resources"
  location = "Canada Central"  # Région Montréal corrigée
}

resource "azurerm_virtual_network" "kami" {
  name                = "kami-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.kalume.location
  resource_group_name = azurerm_resource_group.kalume.name
}

resource "azurerm_subnet" "kami" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.kalume.name
  virtual_network_name = azurerm_virtual_network.kami.name
  address_prefixes     = ["10.0.2.0/24"]
}

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

# Correctement passer la clé publique SSH en tant que variable string,
# cela évite l'erreur liée au chemin
variable "admin_ssh_public_key" {
  type = string
  description = "Clé publique SSH admin (pas comme fichier)"
}

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
