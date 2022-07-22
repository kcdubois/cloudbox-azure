# Bastion host for management access
# These resources are commented out since they're one of the most
# expensive parts of this lab environment. They would replace the
# need for public IPs on management interfaces.


### Variables ###
variable vnet_name {
    type = string
    description = "Name of the virtual network to deploy the Azure Bastion host"
    default = "vnet-cloudbox"
}

variable vnet_resource_group_name {
    type = string
    description = "Name of the resource group containing the virtual network"
    default = "rg-cloudbox-vnet"
}


### Data provider ###
data "azurerm_virtual_network" "vnet" {
    name = var.vnet_name
    resource_group_name = var.vnet_resource_group_name
}

data "azurerm_subnet" "bastion" {
    name = "AzureBastionSubnet"
    virtual_network_name = var.vnet_name
    resource_group_name = var.vnet_resource_group_name
}


### Resources ###
resource "azurerm_public_ip" "bastion" {
  name                = "pip-cloudbox-bastion"
  location            = data.azurerm_virtual_network.vnet.location
  resource_group_name = var.vnet_resource_group_name
  allocation_method   = "Static"
  sku                 = "Standard"
}

resource "azurerm_bastion_host" "cloudbox" {
  name                = "bastion-cloudbox"
  location            = data.azurerm_virtual_network.vnet.location
  resource_group_name = var.vnet_resource_group_name

  ip_configuration {
    name                 = "management"
    subnet_id            = data.azurerm_subnet.bastion.id
    public_ip_address_id = azurerm_public_ip.bastion.id
  }
}


### Terraform configuration ###

terraform {
    cloud {
        organization = "panw-iac-lab"

        workspaces {
            name = "azure-bastion"
        }
    }

    required_providers {
        azurerm = {
            source = "hashicorp/azurerm"
        }
    }
}

provider "azurerm" {
    features {
        virtual_machine {
            delete_os_disk_on_deletion     = false
            graceful_shutdown              = true
            skip_shutdown_and_force_delete = false
        }
    }
}