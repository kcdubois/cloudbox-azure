resource "azurerm_resource_group" "panorama" {
  name = "rg-management-panorama"
  location = var.location
}

module "bootstrap" {
  source = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules//modules/bootstrap"

  resource_group_name  = azurerm_resource_group.panorama.name
  location             = var.location
  storage_account_name = "cloudboxpanbootstrap"
}

module "panorama" {
  source  = "github.com/PaloAltoNetworks/terraform-azurerm-vmseries-modules//modules/panorama"

  resource_group_name = azurerm_resource_group.panorama.name
  location            = var.location
  tags                = var.tags

  panorama_name    = "vm-cloudbox-pra"
  panorama_size    = "Standard_D3_v2"
  panorama_sku     = "byol"
  panorama_version = "latest"

  enable_zones = false

  username = var.username
  password = var.password

  interface = [ // Only one interface in Panorama VM is supported
    {
      name           = "mgmt"
      subnet_id      = azurerm_subnet.management.id
      public_ip      = true
      public_ip_name = "pip-cloudbox-panorama"
      enable_ip_forwarding = false
    }
  ]
  boot_diagnostic_storage_uri = module.bootstrap.storage_account.primary_blob_endpoint
}

output "panorama_public_ip" {
  value = module.panorama.mgmt_ip_address
}
