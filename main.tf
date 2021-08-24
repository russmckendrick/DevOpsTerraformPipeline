# Setup
######################################################################################################


terraform {
  required_version = ">= 1.0.0"
  backend "azurerm" {
  }
  required_providers {
    azurerm = {
      source = "hashicorp/azurerm" # https://registry.terraform.io/providers/hashicorp/azurerm/latest
    }
    azurecaf = {
      source = "aztfmod/azurecaf" # https://registry.terraform.io/providers/aztfmod/azurecaf/latest
    }

  }
}

provider "azurerm" { # Configure the Microsoft Azure RM Provider
  features {
    key_vault {
      purge_soft_delete_on_destroy = true
    }
  }
}

provider "azurecaf" { # Configure the Azure CAF Provider
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

# Create the nsg (bad code)
######################################################################################################

# resource "azurecaf_name" "nsg" {
#   name          = "demo"
#   resource_type = "azurerm_network_security_group"
#   prefixes      = ["dev"]
#   clean_input   = true
# }

# resource "azurecaf_name" "ssh" {
#   name          = "ssh"
#   resource_type = "azurerm_network_security_rule"
#   prefixes      = ["dev"]
#   clean_input   = true
# }

# resource "azurecaf_name" "rdp" {
#   name          = "rdp"
#   resource_type = "azurerm_network_security_rule"
#   prefixes      = ["dev"]
#   clean_input   = true
# }

# resource azurerm_network_security_group "nsg" {
#   name                = azurecaf_name.nsg.result
#   resource_group_name = azurerm_resource_group.resource_group.name
#   location            = azurerm_resource_group.resource_group.location

#   security_rule {
#     access                     = "Allow"
#     direction                  = "Inbound"
#     name                       = azurecaf_name.ssh.result
#     priority                   = 200
#     protocol                   = "TCP"
#     source_address_prefix      = "*"
#     source_port_range          = "*"
#     destination_port_range     = "22-22"
#     destination_address_prefix = "*"
#   }

#   security_rule {
#     access                     = "Allow"
#     direction                  = "Inbound"
#     name                       = azurecaf_name.rdp.result
#     priority                   = 300
#     protocol                   = "TCP"
#     source_address_prefix      = "*"
#     source_port_range          = "*"
#     destination_port_range     = "3389-3389"
#     destination_address_prefix = "*"
#   }
# }

# Create the nsg (good code)
######################################################################################################

# resource "azurecaf_name" "nsg" {
#   name          = "demo"
#   resource_type = "azurerm_network_security_group"
#   prefixes      = ["dev"]
#   clean_input   = true
# }

# resource "azurecaf_name" "ssh" {
#   name          = "ssh"
#   resource_type = "azurerm_network_security_rule"
#   prefixes      = ["dev"]
#   clean_input   = true
# }

# resource "azurecaf_name" "rdp" {
#   name          = "rdp"
#   resource_type = "azurerm_network_security_rule"
#   prefixes      = ["dev"]
#   clean_input   = true
# }

# resource azurerm_network_security_group "nsg" {
#   name                = azurecaf_name.nsg.result
#   resource_group_name = azurerm_resource_group.resource_group.name
#   location            = azurerm_resource_group.resource_group.location

#   security_rule {
#     access                     = "Allow"
#     direction                  = "Inbound"
#     name                       = azurecaf_name.ssh.result
#     priority                   = 200
#     protocol                   = "TCP"
#     source_address_prefix      = "123.123.123.123/32"
#     source_port_range          = "*"
#     destination_port_range     = "22-22"
#     destination_address_prefix = "*"
#   }

#   security_rule {
#     access                     = "Allow"
#     direction                  = "Inbound"
#     name                       = azurecaf_name.rdp.result
#     priority                   = 300
#     protocol                   = "TCP"
#     source_address_prefix      = "123.123.123.123/32"
#     source_port_range          = "*"
#     destination_port_range     = "3389-3389"
#     destination_address_prefix = "*"
#   }
# }


# Create the VM
######################################################################################################
# resource "azurecaf_name" "vnet" {
#   name          = "demo"
#   resource_type = "azurerm_virtual_network"
#   prefixes      = ["dev"]
#   clean_input   = true
# }

# resource "azurecaf_name" "subnet" {
#   name          = "demo"
#   resource_type = "azurerm_virtual_network"
#   prefixes      = ["dev"]
#   suffixes      = ["001"]
#   clean_input   = true
# }

# resource "azurecaf_name" "nsg" {
#   name          = "demo"
#   resource_type = "azurerm_network_security_group"
#   prefixes      = ["dev"]
#   clean_input   = true
# }

# resource "azurecaf_name" "https" {
#   name          = "https"
#   resource_type = "azurerm_network_security_rule"
#   prefixes      = ["dev"]
#   clean_input   = true
# }

# resource "azurecaf_name" "pip" {
#   name          = "demo"
#   resource_type = "azurerm_public_ip"
#   suffixes      = ["dev"]
#   clean_input   = true
# }

# resource "azurecaf_name" "nic" {
#   name          = "demo"
#   resource_type = "azurerm_network_interface"
#   suffixes      = ["dev"]
#   clean_input   = true
# }

# resource "azurecaf_name" "vm" {
#   name          = "demo"
#   resource_type = "azurerm_linux_virtual_machine"
#   suffixes      = ["dev"]
#   clean_input   = true
# }

# resource "azurerm_virtual_network" "vnet" {
#   name                = azurecaf_name.vnet.result
#   address_space       = ["10.0.0.0/16"]
#   location            = azurerm_resource_group.resource_group.location
#   resource_group_name = azurerm_resource_group.resource_group.name
# }

# resource "azurerm_subnet" "subnet" {
#   name                 = azurecaf_name.subnet.resource_type
#   resource_group_name  = azurerm_resource_group.resource_group.name
#   virtual_network_name = azurerm_virtual_network.vnet.name
#   address_prefixes     = ["10.0.0.0/24"]
# }
# resource "azurerm_network_interface" "nic" {
#   name                = azurecaf_name.nic.result
#   resource_group_name = azurerm_resource_group.resource_group.name
#   location            = azurerm_resource_group.resource_group.location

#   ip_configuration {
#     name                          = "primary"
#     subnet_id                     = azurerm_subnet.subnet.id
#     private_ip_address_allocation = "Dynamic"
#   }
# }
# resource "azurerm_network_security_group" "nsg" {
#   name                = azurecaf_name.nsg.result
#   location            = azurerm_resource_group.resource_group.location
#   resource_group_name = azurerm_resource_group.resource_group.name
#   security_rule {
#     access                     = "Allow"
#     direction                  = "Inbound"
#     name                       = azurecaf_name.https.result
#     priority                   = 100
#     protocol                   = "Tcp"
#     source_port_range          = "*"
#     source_address_prefix      = "*"
#     destination_port_range     = "443"
#     destination_address_prefix = azurerm_network_interface.nic.private_ip_address
#   }
# }

# resource "azurerm_network_interface_security_group_association" "main" {
#   network_interface_id      = azurerm_network_interface.nic.id
#   network_security_group_id = azurerm_network_security_group.nsg.id
# }

# resource "random_password" "vm_password" {
#   length      = 24
#   min_upper   = 4
#   min_lower   = 2
#   min_numeric = 4
#   special     = false
# }
# resource "azurerm_linux_virtual_machine" "main" {
#   name                            = azurecaf_name.vm.result
#   resource_group_name             = azurerm_resource_group.resource_group.name
#   location                        = azurerm_resource_group.resource_group.location
#   size                            = var.sku
#   admin_username                  = "adminuser"
#   admin_password                  = random_password.vm_password.result
#   disable_password_authentication = false
#   network_interface_ids = [
#     azurerm_network_interface.nic.id
#   ]

#   source_image_reference {
#     publisher = "Canonical"
#     offer     = "UbuntuServer"
#     sku       = "16.04-LTS"
#     version   = "latest"
#   }

#   os_disk {
#     storage_account_type = "Standard_LRS"
#     caching              = "ReadWrite"
#   }

#   #checkov:skip=CKV_AZURE_1:Ensure Azure Instance does not use basic authentication - this is a test VM which is not accessible externally
# }
