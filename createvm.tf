terraform {
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm"
      version = "2.44.0"
    }
  }
}


provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "ubuntu" {
  name     = "ubuntu-resources"
  location = "australiaeast"
}

resource "azurerm_virtual_network" "ubuntu" {
  name                = "ubuntu-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.ubuntu.location
  resource_group_name = azurerm_resource_group.ubuntu.name
}

resource "azurerm_subnet" "ubuntu" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.ubuntu.name
  virtual_network_name = azurerm_virtual_network.ubuntu.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "ubuntu" {
  name                = "ubuntu-nic"
  location            = azurerm_resource_group.ubuntu.location
  resource_group_name = azurerm_resource_group.ubuntu.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.ubuntu.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.ubuntu.id
  }
}

resource "azurerm_linux_virtual_machine" "ubuntu" {
  name                = "ubuntu-machine"
  resource_group_name = azurerm_resource_group.ubuntu.name
  location            = azurerm_resource_group.ubuntu.location
  size                = "Standard_ds1_v2"
  admin_username      = "adminuser"
  network_interface_ids = [
    azurerm_network_interface.ubuntu.id,
  ]

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
    offer     = "UbuntuServer"
    sku       = "18.04"
    version   = "latest"
  }

}

resource "azurerm_public_ip" "ubuntu" {
  name                = "ubuntu0001publicip1"
  resource_group_name = azurerm_resource_group.ubuntu.name
  location            = azurerm_resource_group.ubuntu.location
  allocation_method   = "Dynamic"

  tags = {
    environment = "Production"
  }
}

resource "azurerm_network_security_group" "ubuntu" {
  name                = "ubuntu-security-group1"
  location            = azurerm_resource_group.ubuntu.location
  resource_group_name = azurerm_resource_group.ubuntu.name

  security_rule {
    name                       = "ssh"
    priority                   = 100
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  tags = {
    environment = "Production"
  }
}
resource "azurerm_network_interface_security_group_association" "ubuntu" {
    network_interface_id      = azurerm_network_interface.ubuntu.id
    network_security_group_id = azurerm_network_security_group.ubuntu.id
}