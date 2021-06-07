# Setup
######################################################################################################

terraform {
  required_version = ">= 0.15.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"  # https://registry.terraform.io/providers/hashicorp/azurerm/latest
      version = "=2.46.0"
    }
    azurecaf = {
      source  = "aztfmod/azurecaf" # https://registry.terraform.io/providers/aztfmod/azurecaf/latest
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

# Configure the Azure CAF Provider
provider "azurecaf" {
}

# Create the resource group
######################################################################################################

resource "azurecaf_name" "rg_example" {
  name          = "demogroup"
  resource_type = "azurerm_resource_group"
  prefixes      = ["dev"]
  clean_input   = true
}

resource "azurerm_resource_group" "resource_group" {
  name     = azurecaf_name.rg_example.result
  location = "uksouth"
  tags     = merge(var.default_tags, tomap({ "type" = "resource" }))
}

resource "azurerm_management_lock" "resource-group-lock" {
  name       = "resource-group-lock"
  scope      = azurerm_resource_group.resource_group.id
  lock_level = "CanNotDelete"
  notes      = "This Resource Group can not be deleted"
}

resource "azurecaf_name" "sa_example" {
  name          = "demogroup"
  resource_type = "azurerm_storage_account"
  prefixes      = ["dev"]
  random_length = 5
  clean_input   = true
}

resource "azurerm_storage_account" "example" {
  name                     = azurecaf_name.sa_example.result
  resource_group_name      = azurerm_resource_group.resource_group.name
  location                 = azurerm_resource_group.resource_group.location
  account_tier             = "Standard"
  account_replication_type = "GRS"
  queue_properties {
    logging {
      delete                = false
      read                  = false
      write                 = true
      version               = "1.0"
      retention_policy_days = 10
    }
    hour_metrics {
      enabled               = true
      include_apis          = true
      version               = "1.0"
      retention_policy_days = 10
    }
    minute_metrics {
      enabled               = true
      include_apis          = true
      version               = "1.0"
      retention_policy_days = 10
    }
  }
}
