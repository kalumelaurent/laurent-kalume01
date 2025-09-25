# Groupe de ressources à Montréal
resource "azurerm_resource_group" "kalume" {
  name     = "example-resources-montreal"
  location = "Canada Central" # Région Montréal/Québec
}

# Réseau virtuel interne
resource "azurerm_virtual_network" "kalume" {
  name                = "internal-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.kalume.location
  resource_group_name = azurerm_resource_group.kalume.name
}

# Sous-réseau pour usage interne
resource "azurerm_subnet" "kalume" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.kalume.name
  virtual_network_name = azurerm_virtual_network.kalume.name
  address_prefixes     = ["10.0.2.0/24"]
}

# Interface réseau associée au subnet interne
resource "azurerm_network_interface" "kalume" {
  name                = "internal-nic"
  location            = azurerm_resource_group.kalume.location
  resource_group_name = azurerm_resource_group.kalume.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.kalume.id
    private_ip_address_allocation = "Dynamic"
  }
}

# Déploiement de la VM Linux sur réseau interne Montréal
resource "azurerm_linux_virtual_machine" "kalume" {
  name                  = "vm-montreal-internal"
  resource_group_name   = azurerm_resource_group.kalume.name
  location              = azurerm_resource_group.kalume.location
  size                  = "Standard_F2"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.kalume.id]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts"
    version   = "latest"
  }
}

