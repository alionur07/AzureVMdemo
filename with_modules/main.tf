provider "azurerm" {
  version                 = "=2.46.0"
  source                  = "hashicorp/azurerm"
  shared_credentials_file = "/root/credentials"
}

module "sentry_setup" {
  source              = "../modules"
  public_key_material = var.public_key_material

  tags = {
    name             = var.name
    project_name     = var.project_name
    environment_name = var.environment_name
    terraform        = var.terraform
  }
}
