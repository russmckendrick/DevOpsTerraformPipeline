# Setup
######################################################################################################

terraform {
  required_version = ">= 0.15.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm" # https://registry.terraform.io/providers/hashicorp/azurerm/latest
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

resource "azurerm_virtual_network" "main" {
  name                = "${var.prefix}-network"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_subnet" "internal" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.resource_group.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_public_ip" "pip" {
  name                = "${var.prefix}-pip"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location
  allocation_method   = "Dynamic"
}

resource "azurerm_network_interface" "main" {
  name                = "${var.prefix}-nic1"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location

  ip_configuration {
    name                          = "primary"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.pip.id
  }
}

resource "azurerm_network_interface" "internal" {
  name                = "${var.prefix}-nic2"
  resource_group_name = azurerm_resource_group.resource_group.name
  location            = azurerm_resource_group.resource_group.location

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.internal.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_network_security_group" "webserver" {
  name                = "tls_webserver"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
  security_rule {
    access                     = "Allow"
    direction                  = "Inbound"
    name                       = "tls"
    priority                   = 100
    protocol                   = "Tcp"
    source_port_range          = "*"
    source_address_prefix      = "*"
    destination_port_range     = "443"
    destination_address_prefix = azurerm_network_interface.main.private_ip_address
  }
}

resource "azurerm_network_interface_security_group_association" "main" {
  network_interface_id      = azurerm_network_interface.internal.id
  network_security_group_id = azurerm_network_security_group.webserver.id
}

resource "azurerm_linux_virtual_machine" "main" {
  name                            = "${var.prefix}-vm"
  resource_group_name             = azurerm_resource_group.resource_group.name
  location                        = azurerm_resource_group.resource_group.location
  size                            = var.sku
  admin_username                  = "adminuser"
  admin_password                  = "P@ssw0rd1234!"
  disable_password_authentication = false
  network_interface_ids = [
    azurerm_network_interface.main.id,
    azurerm_network_interface.internal.id,
  ]

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

  os_disk {
    storage_account_type = "Standard_LRS"
    caching              = "ReadWrite"
  }
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
