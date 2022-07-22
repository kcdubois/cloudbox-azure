variable "location" {
    type = string
    default = "Canada Central"
}

variable "password" {
    type = string
}

data "azurerm_subnet" "vmseries" {
    name = "vmseries"
    virtual_network_name = "vnet-cloudbox"
    resource_group_name = "rg-cloudbox-vnet"
}

resource "azurerm_resource_group" "panorama" {
  name = "rg-canam-panorama"
  location = var.location
}

module "bootstrap" {
  source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules//modules/bootstrap"

  resource_group_name  = azurerm_resource_group.panorama.name
  location             = var.location
  storage_account_name = "canamprapanbootstrap"
}

module "panorama" {
  source  = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules//modules/panorama"

  resource_group_name = azurerm_resource_group.panorama.name
  location            = var.location

  panorama_name    = "vm-canam-pra"
  panorama_size    = "Standard_D3_v2"
  panorama_sku     = "byol"
  panorama_version = "10.1.5"

  enable_zones = false

  username = "panadmin"
  password = var.password

  interface = [ // Only one interface in Panorama VM is supported
    {
      name           = "mgmt"
      subnet_id      = data.azurerm_subnet.vmseries.id
      public_ip      = true
      public_ip_name = "pip-canam-panorama"
      enable_ip_forwarding = false
    }
  ]
  boot_diagnostic_storage_uri = module.bootstrap.storage_account.primary_blob_endpoint
}

output "panorama_public_ip" {
  value = module.panorama.mgmt_ip_address
}

### Terraform configuration ###

terraform {
  cloud {
    organization = "panw-iac-lab"

    workspaces {
      name = "cloudbox-panorama-canam"
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