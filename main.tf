# Setup
######################################################################################################

terraform {
  required_version = ">= 0.15.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}



# Create the resource group
######################################################################################################
resource "azurerm_resource_group" "resource_group" {
  name     = "test-terraform-pipeline-rg"
  location = "uksouth"
  tags     = merge(var.default_tags, tomap({"type" = "resource"}))
}

resource "azurerm_management_lock" "resource-group-lock" {
  name       = "resource-group-lock"
  scope      = azurerm_resource_group.resource_group.id
  lock_level = "CanNotDelete"
  notes      = "This Resource Group can not be deleted"
}