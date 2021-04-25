provider "azurerm" {
    version = "~>2.0"
    features {}
    
    subscription_id = "a964a032-7bc2-4b94-a32b-84812b3077fd"
    client_id       = "2c1ed00e-b879-4ec6-a878-06df88312023"
    client_secret   = "70uhe2ShfIWpvZ1ac-GWj9fmnfiAsNvXX7"
    tenant_id       = "e07d7f2f-071f-42ba-b11e-84aaf24e2494"
}

resource "azurerm_resource_group" "swisscomgroup" {
    name     = "Swisscomm"
    location = "eastus"

    tags = {
        environment = "Swisscom Terraform Case"
    }
}
resource "aws_instance" "sentry" {
  ami = "${lookup(var.ami,var.aws_region)}"
  instance_type = var.instance_type
  key_name      = aws_key_pair.deployer2.key_name
  # VPC
  subnet_id = "${aws_subnet.sentry-subnet-public-1.id}"
  # Security Group
  vpc_security_group_ids = ["${aws_security_group.sentry-ssh-allowed.id}"]

  tags = {
    Name      = lookup(var.tags, "name", "")
    Project   = lookup(var.tags, "project_name", "")
    Env       = lookup(var.tags, "environment_name", "")
    Terraform = lookup(var.tags, "terraform", "true")
  }
provisioner "file" {
    source      = "/root/modules/sentry_install.sh"
    destination = "/tmp/sentry_install.sh"
  }

 # Change permissions on bash script and execute from ec2-user.
  provisioner "remote-exec" {
    inline = [
      "chmod +x /tmp/sentry_install.sh",
      "sudo /tmp/sentry_install.sh",
    ]
  }
# Login to the ec2-user with the aws key.
  connection {
    type        = "ssh"
    user        = "ec2-user"
    password    = ""
    private_key = file(var.keyPath)
    host        = self.public_ip
  }
}

resource "aws_key_pair" "deployer2" {
  key_name   = "deployer2-key"
  public_key = var.public_key_material
}