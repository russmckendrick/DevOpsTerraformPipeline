# Setup
######################################################################################################

# What is the minimum version of Terraform we need?
terraform {
  required_version = ">= 0.12.0"
  backend "azurerm" {}
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=2.46.0"
    }
}

# https://registry.terraform.io/providers/hashicorp/azurerm/latest
provider "azurerm" {
  features {}
}

# Create the resource group
######################################################################################################
resource "azurerm_resource_group" "resource_group" {
  name     = "test-terraform-pipeline-rg"
  location = "uksouth"
  tags     = merge(var.default_tags, map("type", "resource"))
}