module "nsg" {
  source = "Azure/network-security-group/azurerm"

  resource_group_name     = azurerm_resource_group.vnet.name
  location                = azurerm_resource_group.vnet.location
  security_group_name     = "nsg-cloudbox-management"
  source_address_prefixes = ["0.0.0.0/0"]

  predefined_rules = [
    { name = "HTTPS" }
  ]

  tags                    = var.tags
  depends_on = [azurerm_resource_group.vnet]
}

resource "azurerm_subnet_network_security_group_association" "management" {
  subnet_id = azurerm_subnet.management.id
  network_security_group_id = module.nsg.network_security_group_id
}