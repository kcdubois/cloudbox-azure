resource "azurerm_resource_group" "vnet" {
    name = "rg-cloudbox-vnet"
    location = var.location
}

resource "azurerm_virtual_network" "cloudbox-vnet" {
  name = "vnet-cloudbox"
  location = var.location
  resource_group_name = azurerm_resource_group.vnet.name
  address_space = ["10.20.0.0/20"]

  tags = var.tags
}

resource "azurerm_subnet" "management" {
  name = "management"
  virtual_network_name = azurerm_virtual_network.cloudbox-vnet.name
  resource_group_name = azurerm_resource_group.vnet.name
  address_prefixes = ["10.20.15.0/24"]
}

resource "azurerm_subnet" "public" {
  name = "public"
  virtual_network_name = azurerm_virtual_network.cloudbox-vnet.name
  resource_group_name = azurerm_resource_group.vnet.name
  address_prefixes = ["10.20.1.0/24"]
}

resource "azurerm_subnet" "private" {
  name = "private"
  virtual_network_name = azurerm_virtual_network.cloudbox-vnet.name
  resource_group_name = azurerm_resource_group.vnet.name
  address_prefixes = ["10.20.8.0/24"]
}

resource "azurerm_subnet" "daas" {
  name = "daas"
  virtual_network_name = azurerm_virtual_network.cloudbox-vnet.name
  resource_group_name = azurerm_resource_group.vnet.name
  address_prefixes = ["10.20.10.0/24"]
}

resource "azurerm_subnet" "users" {
  name = "users"
  virtual_network_name = azurerm_virtual_network.cloudbox-vnet.name
  resource_group_name = azurerm_resource_group.vnet.name
  address_prefixes = ["10.20.11.0/24"]
}

resource "azurerm_subnet" "gateway" {
  name = "GatewaySubnet"
  virtual_network_name = azurerm_virtual_network.cloudbox-vnet.name
  resource_group_name = azurerm_resource_group.vnet.name
  address_prefixes = ["10.20.0.0/26"]
}

resource "azurerm_subnet" "bastion" {
  name = "AzureBastionSubnet"
  virtual_network_name = azurerm_virtual_network.cloudbox-vnet.name
  resource_group_name = azurerm_resource_group.vnet.name
  address_prefixes = ["10.20.0.64/26"]
}


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