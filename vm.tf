# 1. Groupe de ressources dans la région de Montréal
resource "azurerm_resource_group" "kalume" {
  name     = "kami-resources"
  location = "Canada Central" # Correction de la région pour Montréal
}

# 2. Virtual Network interne
resource "azurerm_virtual_network" "kami" {
  name                = "kami-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.kalume.location
  resource_group_name = azurerm_resource_group.kalume.name
}

# 3. Sous-réseau privé interne
resource "azurerm_subnet" "kami" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.kalume.name
  virtual_network_name = azurerm_virtual_network.kami.name
  address_prefixes     = ["10.0.2.0/24"]
}

# 4. Interface réseau associée au subnet privé
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

# 5. Lecture correcte et compatible de la clé SSH
# Place le fichier public "id_rsa.pub" dans le même dossier que ton code .tf :
variable "ssh_public_key_path" {
  type    = string
  default = "id_rsa.pub"
}

data "local_file" "ssh_key" {
  filename = var.ssh_public_key_path
}

# 6. Création de la VM Debian reliée au réseau privé
resource "azurerm_linux_virtual_machine" "kami" {
  name                  = "debian-vm-montreal"
  resource_group_name   = azurerm_resource_group.kalume.name
  location              = azurerm_resource_group.kalume.location
  size                  = "Standard_F2"
  admin_username        = "adminuser"
  network_interface_ids = [azurerm_network_interface.kami.id]

  admin_ssh_key {
    username   = "adminuser"
    public_key = data.local_file.ssh_key.content
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  # Image officielle Debian Cloud Marketplace
  source_image_reference {
    publisher = "Debian"
    offer     = "debian-11"
    sku       = "11"
    version   = "latest"
  }
}


