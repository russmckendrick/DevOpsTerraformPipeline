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

# Create the nsg
######################################################################################################


resource "azurecaf_name" "nsg" {
  name          = "demo"
  resource_type = "azurerm_network_security_group"
  prefixes      = ["dev"]
  clean_input   = true
}

resource "azurecaf_name" "ssh" {
  name          = "ssh"
  resource_type = "azurerm_network_security_rule"
  prefixes      = ["dev"]
  clean_input   = true
}

resource "azurecaf_name" "rdp" {
  name          = "rdp"
  resource_type = "azurerm_network_security_rule"
  prefixes      = ["dev"]
  clean_input   = true
}

resource azurerm_network_security_group "nsg" {
  name                = azurecaf_name.nsg
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location

  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = azurecaf_name.ssh
    priority                   = 200
    protocol                   = "TCP"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_port_range     = "22-22"
    destination_address_prefix = "*"
  }

  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = azurecaf_name.rdp
    priority                   = 300
    protocol                   = "TCP"
    source_address_prefix      = "*"
    source_port_range          = "*"
    destination_port_range     = "3389-3389"
    destination_address_prefix = "*"
  }
}