resource "azurerm_user_assigned_identity" "user_assigned_identity" {
  name                = var.name
  location            = var.location
  resource_group_name = var.resource_group_name
  tags                = var.tags
}
