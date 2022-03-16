resource "azurerm_resource_group" "vmseries" {
    name = "rg-cloudbox-vmseries"
    location = var.location
}

resource "random_password" "vmseries_password" {
  length           = 16
  min_lower        = 16 - 4
  min_numeric      = 1
  min_special      = 1
  min_upper        = 1
  special          = true
  override_special = "_%@"
}

resource "azurerm_public_ip" "outside_ip" {
    name = "pip-cloudbox-vmseries-outside"
    location = var.location
    resource_group_name = azurerm_resource_group.vmseries.name

    sku = "Standard"
    allocation_method = "Static"
    tags = var.tags
    domain_name_label = "cloudbox-vmseries"
}

module "vmseries" {
  source  = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules//modules/vmseries"

  location            = var.location
  resource_group_name = azurerm_resource_group.vmseries.name
  name                = "vm-cloudbox-vmseries"
  username            = "azureadmin"
  password            = random_password.vmseries_password.result

  bootstrap_options = var.bootstrap_options

  enable_zones = false

  img_sku = "byol"
  img_version = "10.1.4"

  interfaces = [
    {
      name      = "management"
      subnet_id = azurerm_subnet.management.id
    },
    {
      name      = "public"
      subnet_id = azurerm_subnet.public.id,
      public_ip_address_id = azurerm_public_ip.outside_ip.id
    },
    {
      name      = "private"
      subnet_id = azurerm_subnet.private.id,
      enable_ip_forwarding = true
    }
  ]
}

output "vmseries_password" {
    value = random_password.vmseries_password.result
    sensitive = true
}