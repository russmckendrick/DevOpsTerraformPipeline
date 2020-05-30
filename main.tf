# Setup
######################################################################################################

# What is the minimum version of Terraform we need?
terraform {
  required_version = ">= 0.12.0"
  backend "azurerm" {}
}

# https://registry.terraform.io/providers/hashicorp/azurerm/
provider "azurerm" {
  version = "=2.0"
  features {}
}

# Create the resource group
######################################################################################################
resource "azurerm_resource_group" "resource_group" {
  name     = "test-terraform-pipeline-rg"
  location = "uksouth"
  tags     = merge(var.default_tags, map("type", "resource"))
}