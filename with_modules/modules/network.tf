# Create virtual network
resource "azurerm_virtual_network" "swisscomnetwork" {
    name                = "SwisscomVnet"
    address_space       = ["10.0.0.0/16"]
    location            = "eastus"
    resource_group_name = azurerm_resource_group.swisscomgroup.name

    tags = {
        environment = "Swisscom Terraform Case"
    }
}

# Create subnet
resource "azurerm_subnet" "swisscomsubnet" {
    name                 = "swisscomSubnet"
    resource_group_name  = azurerm_resource_group.swisscomgroup.name
    virtual_network_name = azurerm_virtual_network.swisscomnetwork.name
    address_prefixes       = ["10.0.1.0/24"]
}

# Create public IPs
resource "azurerm_public_ip" "swisscompublicip" {
    name                         = "swisscomPublicIP"
    location                     = "eastus"
    resource_group_name          = azurerm_resource_group.swisscomgroup.name
    allocation_method            = "Dynamic"

    tags = {
        environment = "Swisscom Terraform Case"
    }
}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "swisscomnsg" {
    name                = "swisscomSecurityGroup"
    location            = "eastus"
    resource_group_name = azurerm_resource_group.swisscomgroup.name

    security_rule {
        name                       = "SSH"
        priority                   = 1001
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "22"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Swisscom Terraform Case"
    }
}

# Create network interface
resource "azurerm_network_interface" "swisscomnic" {
    name                      = "swisscomNIC"
    location                  = "eastus"
    resource_group_name       = azurerm_resource_group.swisscomgroup.name

    ip_configuration {
        name                          = "NicConfiguration"
        subnet_id                     = azurerm_subnet.swisscomsubnet.id
        private_ip_address_allocation = "Dynamic"
        public_ip_address_id          = azurerm_public_ip.swisscompublicip.id
    }

    tags = {
        environment = "Swisscom Terraform Case"
    }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "swisscom" {
    network_interface_id      = azurerm_network_interface.swisscomnic.id
    network_security_group_id = azurerm_network_security_group.swisscomnsg.id
}