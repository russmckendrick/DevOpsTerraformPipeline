# Setup
######################################################################################################

terraform {
  required_version = ">= 0.15.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
    azurecaf = {
      source = "aztfmod/azurecaf"
      version = "1.2.3"
    }
  }
  backend "azurerm" {
  }
}

# Configure the Microsoft Azure Provider
provider "azurerm" {
  features {}
}

provider "azurecaf" {
  features {}
}

# Create the resource group
######################################################################################################

resource "azurecaf_name" "rg_example" {
  name            = "demogroup"
    resource_type   = "azurerm_resource_group"
    prefixes        = ["a", "b"]
    suffixes        = ["y", "z"]
    random_length   = 5
    clean_input     = true
}

resource "azurerm_resource_group" "resource_group" {
  name     = azurecaf_name.rg_example.result
  location = "uksouth"
  tags     = merge(var.default_tags, tomap({"type" = "resource"}))
}

resource "azurerm_management_lock" "resource-group-lock" {
  name       = "resource-group-lock"
  scope      = azurerm_resource_group.resource_group.id
  lock_level = "CanNotDelete"
  notes      = "This Resource Group can not be deleted"
}
