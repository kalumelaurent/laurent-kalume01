# 1. Groupe de ressources à Montréal (Canada Central)
resource "azurerm_resource_group" "kalume" {
  name     = "example-resources-montreal"
  location = "Canada Central" # Correction pour la région Montréal/Québec
}

# 2. Réseau virtuel dédié, adresse privée
resource "azurerm_virtual_network" "kami" {
  name                = "kami-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.kalume.location
  resource_group_name = azurerm_resource_group.kalume.name
}

# 3. Sous-réseau interne
resource "azurerm_subnet" "kami" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.kalume.name
  virtual_network_name = azurerm_virtual_network.kami.name
  address_prefixes     = ["10.0.2.0/24"]
}

# 4. Interface réseau reliée au subnet privé
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

# 5. VM Linux Debian sur le réseau privé Montréal
resource "azurerm_linux_virtual_machine" "kami" {
  name                  = "debian-vm-montreal"
  resource_group_name   = azurerm_resource_group.kalume.name
  location              = azurerm_resource_group.kalume.location
  size                  = "Standard_F2"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.kami.id]

  admin_ssh_key {
    username   = "adminuser"
    public_key = file("~/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Image officielle Debian 11 (Bullseye)
  source_image_reference {
    publisher = "Debian"
    offer     = "debian-11"
    sku       = "11"
    version   = "latest"
  }
}
