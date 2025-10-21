resource "azurerm_subnet" "snet_azure_function" {
  count = var.include_networking ? 1 : 0

  name                 = "snet-azure-function"
  resource_group_name  = var.networking_resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.azure_function_subnet_cidr_block]

  delegation {
    name = "ServerFarms delegation"
    service_delegation {
      name = "Microsoft.Web/serverFarms"
    }
  }
}

locals {
  snet_azure_function_id = var.include_networking ? azurerm_subnet.snet_azure_function[0].id : null
}

resource "azurerm_network_security_rule" "allow_snet_azure_function_to_snet_data_platform" {
  count = var.include_networking ? 1 : 0

  name                        = "AllowAzureFunctionToDataPlatform"
  priority                    = 100
  direction                   = "Inbound"
  access                      = "Allow"
  protocol                    = "Tcp"
  source_port_range           = "*"
  destination_port_range      = "*"
  source_address_prefix       = var.azure_function_subnet_cidr_block
  destination_address_prefix  = "*"
  resource_group_name         = var.networking_resource_group_name
  network_security_group_name = var.data_platform_nsg_name
}

resource "azurerm_storage_account" "app_storage_account" {
  name                     = var.storage_account_name
  location                 = var.location
  resource_group_name      = var.resource_group_name
  account_tier             = "Standard"
  account_replication_type = "LRS"
  tags                     = var.tags
}

resource "azurerm_service_plan" "asp" {
  name                = "asp-${var.name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  os_type             = "Linux"
  sku_name            = var.sku_name
  tags                = var.tags
}

resource "azurerm_linux_function_app" "function" {
  name                       = var.name
  location                   = var.location
  resource_group_name        = var.resource_group_name
  service_plan_id            = azurerm_service_plan.asp.id
  storage_account_name       = azurerm_storage_account.app_storage_account.name
  storage_account_access_key = azurerm_storage_account.app_storage_account.primary_access_key

  public_network_access_enabled = !var.include_networking

  identity {
    type         = "SystemAssigned, UserAssigned"
    identity_ids = var.user_assigned_identity_ids
  }

  site_config {
    always_on = var.kind == "ASP" ? true : false

    # TODO: allow for docker runtime
    application_stack {
      python_version          = var.runtime.language == "Python" ? var.runtime.version : null
      dotnet_version          = var.runtime.language == ".NET" ? var.runtime.version : null
      java_version            = var.runtime.language == "Java" ? var.runtime.version : null
      node_version            = var.runtime.language == "JavaScript" ? var.runtime.version : null
      powershell_core_version = var.runtime.language == "PowerShell" ? var.runtime.version : null
    }

    ip_restriction_default_action     = var.include_networking ? "Deny" : "Allow"
    scm_ip_restriction_default_action = var.include_networking ? "Deny" : "Allow"

    ip_restriction {
      action     = "Allow"
      ip_address = var.data_platform_subnet_cidr_block
      priority   = 100
    }

    scm_ip_restriction {
      action     = "Allow"
      ip_address = var.data_platform_subnet_cidr_block
      priority   = 100
    }
  }

  virtual_network_subnet_id = var.include_networking ? local.snet_azure_function_id : null

  tags = var.tags
}

module "pep_function_sites" {
  count = var.include_networking ? 1 : 0

  source                = "../private_endpoint"
  name                  = "pep-function-sites-${var.environment}"
  location              = var.location
  resource_group_name   = var.networking_resource_group_name
  subnet_id             = var.data_platform_subnet_id
  private_ip_address    = var.pep_sites_ip
  resource_id           = azurerm_linux_function_app.function.id
  resource_name         = azurerm_linux_function_app.function.name
  subresource_name      = "sites"
  member_name           = "sites"
  private_dns_zone_name = "privatelink.azurewebsites.net"
  virtual_network_id    = var.vnet_id
  tags                  = var.tags
}
