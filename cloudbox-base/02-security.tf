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

module "internal" {
  source = "Azure/network-security-group/azurerm"

  resource_group_name     = azurerm_resource_group.vnet.name
  location                = azurerm_resource_group.vnet.location
  security_group_name     = "nsg-cloudbox-vmseries-private"
  source_address_prefixes = ["10.20.0.0/20"]

  custom_rules = [
    {
      name                   = "AllowOutbound"
      priority               = 100
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "*"
      source_port_range      = "*"
      destination_port_range = "*"
      source_address_prefix  = "10.20.0.0/20"
      description            = "Allow internal subnets to Internet"
    }
  ]

  tags                    = var.tags
  depends_on = [azurerm_resource_group.vnet]
}

module "vmseries-public" {
  source = "Azure/network-security-group/azurerm"

  resource_group_name     = azurerm_resource_group.vnet.name
  location                = azurerm_resource_group.vnet.location
  security_group_name     = "nsg-cloudbox-vmseries-public"
  source_address_prefixes = ["0.0.0.0/0"]

  predefined_rules = [
    { name = "HTTPS" }
  ]

  custom_rules = [
    {
      name                   = "Allow ICMP"
      priority               = 1000
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "ICMP"
      source_port_range      = "*"
      destination_port_range = "*"
      source_address_prefix = "Internet"
      description            = "Allow internal subnets to Internet"
    },
     {
      name                   = "AllowOutbound"
      priority               = 2000
      direction              = "Inbound"
      access                 = "Allow"
      protocol               = "*"
      source_port_range      = "*"
      destination_port_range = "*"
      source_address_prefix  = "*"
      description            = "Allow All"
    }
  ]

  tags                    = var.tags
  depends_on = [azurerm_resource_group.vnet]
}


resource "azurerm_subnet_network_security_group_association" "vmseries" {
  subnet_id = azurerm_subnet.vmseries.id
  network_security_group_id = module.nsg.network_security_group_id
}

resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id = azurerm_subnet.private.id
  network_security_group_id = module.internal.network_security_group_id
}

resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id = azurerm_subnet.public.id
  network_security_group_id = module.vmseries-public.network_security_group_id
}