module "GatewaySubnet" {
  source              = "../subnet"
  name                = "GatewaySubnet"
  resource_group_name = var.resource_group_name
  vnet_name           = var.vnet_name
  cidr_block          = var.GatewaySubnet_cidr_block
}

resource "azurerm_public_ip" "public_ip_vgw" {
  name                = "pip-vgw"
  location            = var.location
  resource_group_name = var.resource_group_name
  allocation_method   = "Static"
  tags                = var.tags
}

resource "azurerm_virtual_network_gateway" "vgw" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name

  type = "Vpn"
  sku  = "VpnGw1"

  ip_configuration {
    name                          = "vnetGatewayConfig"
    public_ip_address_id          = azurerm_public_ip.public_ip_vgw.id
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = module.GatewaySubnet.subnet_id
  }

  vpn_client_configuration {
    address_space        = [var.vpn_configuration_address_space_cidr_block]
    aad_tenant           = "https://login.microsoftonline.com/${var.tenant_id}/"
    aad_audience         = var.vpn_application_id
    aad_issuer           = "https://sts.windows.net/${var.tenant_id}/"
    vpn_client_protocols = ["OpenVPN"]
  }
  tags = var.tags
}
