# Bastion host for management access
# These resources are commented out since they're one of the most
# expensive parts of this lab environment. They would replace the
# need for public IPs on management interfaces.

#resource "azurerm_public_ip" "bastion" {
#  name                = "pip-cloudbox-bastion"
#  location            = azurerm_resource_group.vnet.location
#  resource_group_name = azurerm_resource_group.vnet.name
#  allocation_method   = "Static"
#  sku                 = "Standard"
#}

#resource "azurerm_bastion_host" "cloudbox" {
#  name                = "bastion-cloudbox"
# location            = azurerm_resource_group.vnet.location
#  resource_group_name = azurerm_resource_group.vnet.name
#
#  ip_configuration {
#    name                 = "management"
#    subnet_id            = azurerm_subnet.bastion.id
#    public_ip_address_id = azurerm_public_ip.bastion.id
#  }
#
#  tags = var.tags
#}