# Route tables 
resource "azurerm_route_table" "internal" {
  name = "rt-cloudbox-default-vmseries"
  location = var.location
  resource_group_name = azurerm_resource_group.vnet.name
}

resource "azurerm_route" "default_vmseries" {
  name = "route-cloudbox-to-vmseries-private"
  resource_group_name = azurerm_resource_group.vnet.name
  route_table_name = azurerm_route_table.internal.name

  address_prefix = "0.0.0.0/0"
  next_hop_type = "VirtualAppliance"
  next_hop_in_ip_address = module.vmseries.interfaces[2].private_ip_address
}

resource "azurerm_subnet_route_table_association" "daas" {
  subnet_id      = azurerm_subnet.daas.id
  route_table_id = azurerm_route_table.internal.id
}

resource "azurerm_subnet_route_table_association" "users" {
  subnet_id      = azurerm_subnet.users.id
  route_table_id = azurerm_route_table.internal.id
}