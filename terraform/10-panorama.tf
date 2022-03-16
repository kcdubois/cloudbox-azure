resource "azurerm_resource_group" "panorama" {
  name = "rg-management-panorama"
  location = var.location
}

module "nsg" {
  source = "Azure/network-security-group/azurerm"

  resource_group_name     = azurerm_resource_group.panorama.name
  location                = var.location
  security_group_name     = "nsg-cloudbox-panorama"
  source_address_prefixes = ["10.20.0.0/20"]
  tags                    = var.tags

  predefined_rules = [
    { name = "HTTPS" }
  ]

  depends_on = [azurerm_resource_group.panorama]
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

  username = "azureadmin"
  password = random_password.panorama_password.result

  interface = [ // Only one interface in Panorama VM is supported
    {
      name           = "mgmt"
      subnet_id      = azurerm_subnet.management.id
      public_ip      = false
    }
  ]
  boot_diagnostic_storage_uri = module.bootstrap.storage_account.primary_blob_endpoint
}

output "panorama_public_ip" {
  value = module.panorama.mgmt_ip_address
}

output "panorama_password" {
  value = random_password.panorama_password.result
  sensitive = true
}