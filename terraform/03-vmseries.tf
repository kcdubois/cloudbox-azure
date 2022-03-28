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
  img_version = "10.1.4"

  interfaces = [
    {
      name      = "management"
      subnet_id = azurerm_subnet.management.id
      public_ip_address_id = azurerm_public_ip.management_ip.id
    },
    {
      name      = "public"
      subnet_id = azurerm_subnet.public.id,
      public_ip_address_id = azurerm_public_ip.outside_ip.id
      enable_ip_forwarding = true
    },
    {
      name      = "private"
      subnet_id = azurerm_subnet.private.id,
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