### Variables ###

data "azurerm_subnet" "management" {
    name = "Management"
    virtual_network_name = "vnet-cloudbox"
    resource_group_name = "rg-cloudbox-vnet"
}


resource "azurerm_resource_group" "this" {
    name = "rg-cloudbox-duo"
    location = "Canada Central"
}

resource "azurerm_network_interface" "nic" {
  name                = "management"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.management.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.20.15.75"
  }
}

resource "azurerm_linux_virtual_machine" "duo" {
  name                = "vm-cloudbox-duo"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  size                = "Standard_B1s"
  admin_username      = "azureadmin"
  admin_password = "PaloAltoNetworks1!"
  disable_password_authentication = false
  
  network_interface_ids = [
    azurerm_network_interface.nic.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-focal"
    sku       = "20_04-lts-gen2"
    version   = "latest"
  }
}


### Terraform configuration ###

terraform {
    cloud {
        organization = "panw-iac-lab"

        workspaces {
            name = "azure-mfa-gp"
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