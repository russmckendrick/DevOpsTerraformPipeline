# Setup
######################################################################################################

# What is the minimum version of Terraform we need?
terraform {
  required_version = ">= 0.12.0"
}

# https://registry.terraform.io/providers/hashicorp/azurerm/
provider "azurerm" {
  version = "=2.0"
  features {}
}

