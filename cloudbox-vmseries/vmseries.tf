variable "tags" {
    type = map(string)
    default = {
        "project": "cloudbox"
    }
}

variable "location" {
    type = string
    default = "Canada Central"
}

variable "username" {
    type = string
    description = "Username of the default administrator"
    default = "azureadmin"
}

variable "password" {
    type = string
    description = "Password used for workload VMs. NOT MEANT TO BE A PRODUCTION-GRADE setup"
}

variable "bootstrap_options" {
    type = string
    description = "Custom data sent to the VM-Series to license it"
}


data "azurerm_subnet" "vmseries" {
    name = "vmseries"
    virtual_network_name = "vnet-cloudbox"
    resource_group_name = "rg-cloudbox-vnet"
}

data "azurerm_subnet" "public" {
    name = "public"
    virtual_network_name = "vnet-cloudbox"
    resource_group_name = "rg-cloudbox-vnet"
}

data "azurerm_subnet" "private" {
    name = "private"
    virtual_network_name = "vnet-cloudbox"
    resource_group_name = "rg-cloudbox-vnet"
}


resource "azurerm_resource_group" "vmseries" {
    name = "rg-cloudbox-vmseries"
    location = var.location
}

resource "azurerm_public_ip" "management_ip" {
    name = "pip-cloudbox-vmseries-mgmt"
    location = var.location
    resource_group_name = azurerm_resource_group.vmseries.name

    sku = "Standard"
    allocation_method = "Static"
    tags = var.tags
}

resource "azurerm_public_ip" "outside_ip" {
    name = "pip-cloudbox-vmseries-outside"
    location = var.location
    resource_group_name = azurerm_resource_group.vmseries.name

    sku = "Standard"
    allocation_method = "Static"
    tags = var.tags
}

module "vmseries" {
  source  = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules//modules/vmseries"

  location            = var.location
  resource_group_name = azurerm_resource_group.vmseries.name
  name                = "vm-cloudbox-vmseries"
  username            = var.username
  password            = var.password

  bootstrap_options = var.bootstrap_options

  enable_zones = false

  img_sku = "byol"
  img_version = "10.1.0"

  interfaces = [
    {
      name      = "management"
      subnet_id = data.azurerm_subnet.vmseries.id
      public_ip_address_id = azurerm_public_ip.management_ip.id
    },
    {
      name      = "public"
      subnet_id = data.azurerm_subnet.public.id,
      public_ip_address_id = azurerm_public_ip.outside_ip.id
      enable_ip_forwarding = true
    },
    {
      name      = "private"
      subnet_id = data.azurerm_subnet.private.id,
      enable_ip_forwarding = true
    }
  ]

  depends_on = [
    azurerm_public_ip.management_ip,
    azurerm_public_ip.outside_ip
  ]
}

output "vmseries_management_ip" {
  value = azurerm_public_ip.management_ip.ip_address
}
output "vmseries_outside_ip" {
  value = azurerm_public_ip.outside_ip.ip_address
}

terraform {
    cloud {
        organization = "panw-iac-lab"

        workspaces {
            name = "cloudbox-vmseries"
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