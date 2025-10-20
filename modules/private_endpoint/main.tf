resource "azurerm_private_endpoint" "private_endpoint" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_id

  ip_configuration {
    name               = "${var.name}-ip-config"
    private_ip_address = var.private_ip_address
    subresource_name   = var.subresource_name
    member_name        = var.member_name
  }

  private_service_connection {
    name                           = "${var.name}-privateserviceconnection"
    private_connection_resource_id = var.resource_id
    subresource_names              = [var.subresource_name]
    is_manual_connection           = false
  }

  tags = var.tags
}

resource "azurerm_private_dns_zone" "private_dns_zone" {
  name                = var.private_dns_zone_name
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

resource "azurerm_private_dns_zone_virtual_network_link" "private_dns_zone_virtual_network_link" {
  name                  = "vnet-link"
  resource_group_name   = var.resource_group_name
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_zone.name
  virtual_network_id    = var.virtual_network_id
  tags                  = var.tags
}

resource "azurerm_private_dns_a_record" "dns_a_record" {
  name                = var.resource_name
  zone_name           = azurerm_private_dns_zone.private_dns_zone.name
  resource_group_name = var.resource_group_name
  ttl                 = 10
  records             = [var.private_ip_address]
  tags                = var.tags
}
