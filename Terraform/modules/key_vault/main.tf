resource "azurerm_key_vault" "key_vault" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku_name            = "standard"
  tenant_id           = var.tenant_id

  purge_protection_enabled  = true
  enable_rbac_authorization = true

  public_network_access_enabled = !var.include_networking

  tags = var.tags
}

module "pep_vault" {
  count = var.include_networking ? 1 : 0

  source                = "../private_endpoint"
  name                  = "pep-keyvault-${var.environment}"
  location              = var.location
  resource_group_name   = var.networking_resource_group_name
  subnet_id             = var.data_platform_subnet_id
  private_ip_address    = var.pep_vault_ip
  resource_id           = azurerm_key_vault.key_vault.id
  resource_name         = azurerm_key_vault.key_vault.name
  subresource_name      = "vault"
  member_name           = "default"
  private_dns_zone_name = "privatelink.vaultcore.azure.net"
  virtual_network_id    = var.vnet_id
  tags                  = var.tags
}
