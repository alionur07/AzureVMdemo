# Configure the Microsoft Azure Provider
provider "azurerm" {
    # The "feature" block is required for AzureRM provider 2.x. 
    # If you're using version 1.x, the "features" block is not allowed.
    version = "=2.56.0"
    features {}
    
    subscription_id = "a964a032-7bc2-4b94-a32b-84812b3077fd"
    client_id       = "2c1ed00e-b879-4ec6-a878-06df88312023"
    client_secret   = "70uhe2ShfIWpvZ1ac-GWj9fmnfiAsNvXX7"
    tenant_id       = "e07d7f2f-071f-42ba-b11e-84aaf24e2494"
}

# Create a resource group if it doesn't exist
resource "azurerm_resource_group" "swisscomgroup" {
    name     = "Swisscomm"
    location = "eastus"

    tags = {
        environment = "Swisscom Terraform Case"
    }
}

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

    security_rule {
        name                       = "HTTP-80"
        priority                   = 1002
        direction                  = "Inbound"
        access                     = "Allow"
        protocol                   = "Tcp"
        source_port_range          = "*"
        destination_port_range     = "80"
        source_address_prefix      = "*"
        destination_address_prefix = "*"
    }

    tags = {
        environment = "Swisscom Terraform Case"
    }
}

# Create network interface
resource  "azurerm_network_interface" "swisscomnic" {
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

# Generate random text for a unique storage account name
resource "random_id" "randomId" {
    keepers = {
        # Generate a new ID only when a new resource group is defined
        resource_group = azurerm_resource_group.swisscomgroup.name
    }

    byte_length = 8
}

# Create storage account for boot diagnostics
resource "azurerm_storage_account" "swisscomstorageaccount" {
    name                        = "diag${random_id.randomId.hex}"
    resource_group_name         = azurerm_resource_group.swisscomgroup.name
    location                    = "eastus"
    account_tier                = "Standard"
    account_replication_type    = "LRS"

    tags = {
        environment = "Swisscom Terraform Case"
    }
}

# Create (and display) an SSH key
/*
  resource "tls_private_key" "ubuntu_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}
output "tls_private_key" {
     value = tls_private_key.ubuntu_ssh.private_key_pem 
     sensitive = true
     }
*/
# Create virtual machine
resource "azurerm_linux_virtual_machine" "swisscomvm" {
    name                  = "CaseUbuntuVM"
    location              = "eastus"
    resource_group_name   = azurerm_resource_group.swisscomgroup.name
    network_interface_ids = [azurerm_network_interface.swisscomnic.id]
    size                  = "Standard_DS1_v2"

    os_disk {
        name              = "myOsDisk"
        caching           = "ReadWrite"
        storage_account_type = "Premium_LRS"
    }

    source_image_reference {
        publisher = "Canonical"
        offer     = "UbuntuServer"
        sku       = "18.04-LTS"
        version   = "latest"
    }
   
    
        computer_name  = "SwisscomCaseStudyVm"
        admin_username = "swisscom"
        admin_password = "Swisscom!"
        disable_password_authentication = false
    

    admin_ssh_key {
        username       = "swisscom"
       # public_key     = tls_private_key.ubuntu_ssh.public_key_openssh
        public_key     = "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAABAQCnmzyNA46/zouIrCZ4JgOEK2nc5UEq/eHz82KE13EbBbI5+boNN+5COwhGp8zqr52/XOwpF0pFiEBJ251Ftr5jnQC3II+XYqg1W0brIItzQHROj/fxC2f2RbJkVhmE2oOuUAgdG+fa9uQNpCgyjGsY1Lm1aJrucdHgB5MIKqPNQe663U5sgYC3QsWudbZeXP/w9sjFcR4zjfKJiVeVoR8huout0ytVOGr8i6ukwPyo+HAk0DU/VlDDtxJOUYXIlyqQGt2aJ6nrJUiwcmOqTeZlDTmgDhkx3UcMhsYAyFYQ9RuK+8ATupc/fNaJf3BwoYJiBGmHAPRDrRNwfhOsTORX ali@ubuntuJobAgent"
       # private_key    = "~/.ssh/id_rsa"
    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.swisscomstorageaccount.primary_blob_endpoint
    }

    tags = {
        environment = "Swisscom Terraform Case"
    }

provisioner "file" {
    source      = "dockerinstallandrun.sh"
    destination = "/tmp/dockerinstallandrun.sh"
  }


 # Change permissions on bash script and execute from ec2-user.
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/dockerinstallandrun.sh",
      "sudo /tmp/dockerinstallandrun.sh",
    ]
  }

    connection {
    type     = "ssh"
    user     = "swisscom"
    password = "Swisscom!"
    host     = azurerm_linux_virtual_machine.swisscomvm.public_ip_address
  }


}

output "public_ip_address" {
    value = azurerm_linux_virtual_machine.swisscomvm.public_ip_address
}