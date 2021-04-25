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
resource "tls_private_key" "ubuntu_ssh" {
  algorithm = "RSA"
  rsa_bits = 4096
}
output "tls_private_key" {
     value = tls_private_key.ubuntu_ssh.private_key_pem 
     sensitive = true
     }

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
    disable_password_authentication = true

    admin_ssh_key {
        username       = "swisscom"
        public_key     = tls_private_key.ubuntu_ssh.public_key_openssh
    }

#    output "admin_ssh_key" {
#     value = tls_private_key.ubuntu_ssh.public_key_openssh
     
#    }

    boot_diagnostics {
        storage_account_uri = azurerm_storage_account.swisscomstorageaccount.primary_blob_endpoint
    }

}