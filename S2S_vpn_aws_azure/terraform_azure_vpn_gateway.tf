provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "resource_group" {
  name     = "azure_resource_group"
  location = "West EU"
}

resource "azurerm_virtual_network" "virtual_network" {
  name                = "azure_virtual_net"
  address_space       = ["10.1.0.0/16"]
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name
}

resource "azurerm_virtual_network_gateway" "vpn_gateway" {
  name                = "azure_vpn_gateway"
  location            = azurerm_resource_group.resource_group.location
  resource_group_name = azurerm_resource_group.resource_group.name

  type     = "Vpn"
  vpn_type = "RouteBased"

  ip_configuration {
    name                          = "virtualnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.public_ip.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.gateway_subnet.id
  }
}

