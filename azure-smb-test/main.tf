data "azurerm_subnet" "public" {
    name = "public"
    virtual_network_name = "vnet-cloudbox"
    resource_group_name = "rg-cloudbox-vnet"
}

resource "azurerm_resource_group" "this" {
    name = "rg-cloudbox-vm-file1"
    location = "Canada Central"
}

resource "azurerm_public_ip" "outside_ip" {
    name = "pip-cloudbox-file1"
    location = azurerm_resource_group.this.location
    resource_group_name = azurerm_resource_group.this.name

    sku = "Standard"
    allocation_method = "Static"
}

resource "azurerm_network_interface" "nic" {
  name                = "nic-cloudbox-file1"
  location            = azurerm_resource_group.this.location
  resource_group_name = azurerm_resource_group.this.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = data.azurerm_subnet.public.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.outside_ip.id
  }
}


resource "azurerm_windows_virtual_machine" "vm" {
  name                = "vm-file1"
  resource_group_name = azurerm_resource_group.this.name
  location            = azurerm_resource_group.this.location
  size                = "Standard_B2s"
  admin_username      = "azureadmin"
  admin_password      = "PaloAltoNetworks1!"

  network_interface_ids = [
    azurerm_network_interface.nic.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}

### Terraform ###


terraform {
    cloud {
        organization = "panw-iac-lab"

        workspaces {
            name = "azure-smb-test"
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

    }
}