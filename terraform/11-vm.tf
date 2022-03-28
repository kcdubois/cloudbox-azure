resource "azurerm_resource_group" "vms" {
    name = "rg-cloudbox-vms"
    location = var.location
}

resource "azurerm_network_interface" "msft-dc" {
  name                = "nic-cloudbox-msft-dc"
  location            = azurerm_resource_group.vms.location
  resource_group_name = azurerm_resource_group.vms.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.management.id
    private_ip_address_allocation = "Static"
    private_ip_address = "10.20.15.65"
  }
}

resource "azurerm_windows_virtual_machine" "msft-dc" {
  name                = "msft-dc"
  resource_group_name = azurerm_resource_group.vms.name
  location            = azurerm_resource_group.vms.location
  size                = "Standard_B2s"
  admin_username      = var.username
  admin_password      = var.password

  network_interface_ids = [
    azurerm_network_interface.msft-dc.id
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}