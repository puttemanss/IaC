data "azurerm_client_config" "current" {}

##################################################
################ ASSEMBLE VNET_ID ################
##################################################
locals {
  vnet_id = "/subscriptions/${var.subscription_id}/resourceGroups/${var.networking_resource_group_name}/providers/Microsoft.Network/virtualNetworks/${var.vnet_name}"

  tags = {
    Owner       = var.owner
    Project     = var.project_tag_name
    Environment = var.environment
    # Cost Center
  }
}

################################################
################ RESOURCE GROUP ################
################################################
module "resource_group_data" {
  source   = "./modules/resource_group"
  name     = "rg-${var.company_abbreviation}-${var.project_name}-${var.environment}"
  location = var.location
  tags     = local.tags
}

######################################################
################ DATA PLATFORM SUBNET ################
######################################################
resource "azurerm_network_security_group" "nsg_data_platform" {
  count = var.include_networking ? 1 : 0

  name                = "nsg-data-platform-${var.environment}"
  location            = var.location
  resource_group_name = var.networking_resource_group_name
  tags                = local.tags
}
module "data_platform_subnet" {
  count = var.include_networking ? 1 : 0

  source              = "./modules/subnet"
  name                = "snet-data-platform-${var.environment}"
  resource_group_name = var.networking_resource_group_name
  vnet_name           = var.vnet_name
  cidr_block          = var.data_platform_subnet_cidr_block
}

locals {
  data_platform_subnet_id = var.include_networking ? module.data_platform_subnet[0].subnet_id : ""
  nsg_data_platform_id    = var.include_networking ? azurerm_network_security_group.nsg_data_platform[0].id : ""
  nsg_data_platform_name  = var.include_networking ? azurerm_network_security_group.nsg_data_platform[0].name : ""
}

resource "azurerm_subnet_network_security_group_association" "nsg_data_platform_subnet" {
  count = var.include_networking ? 1 : 0

  subnet_id                 = local.data_platform_subnet_id
  network_security_group_id = local.nsg_data_platform_id
}

####################################################
################ CONNECTION METHODS ################
####################################################
module "connection_methods" {
  count = var.include_networking ? 1 : 0

  source                         = "./modules/vnet_connectivity"
  location                       = var.location
  networking_resource_group_name = var.networking_resource_group_name
  project_name                   = var.project_name
  environment                    = var.environment

  include_vpn_connection                     = var.include_vpn_connection
  vpn_vnet_name                              = var.vnet_name
  vpn_GatewaySubnet_cidr_block               = var.gateway_subnet_cidr_block
  vpn_application_id                         = var.vpn_application_id
  vpn_tenant_id                              = var.tenant_id
  vpn_configuration_address_space_cidr_block = var.vpn_configuration_address_space_cidr_block

  include_vm_connection     = var.include_vm_connection
  vm_resource_group_name    = module.resource_group_data.resource_group_name
  vm_size                   = var.vm_size
  vm_admin_username         = var.vm_admin_username
  vm_admin_password         = var.vm_admin_password
  vm_nic_subnet_id          = local.data_platform_subnet_id
  vm_nic_ip_address         = var.vm_private_ip
  vm_source_image_reference = var.vm_source_image_reference

  tags = local.tags
}

##########################################################
################ USER ASSIGNED IDENTITIES ################
##########################################################
module "user_assigned_identity_dls_data_contributor" {
  count = var.include_storage_account ? 1 : 0

  source              = "./modules/user_assigned_identity"
  name                = "uai-${var.company_abbreviation}-${var.project_name}-${var.environment}-dls-data-contributor"
  location            = var.location
  resource_group_name = module.resource_group_data.resource_group_name
  tags                = local.tags
}

module "user_assigned_identity_key_vault_secrets_officer" {
  source              = "./modules/user_assigned_identity"
  name                = "uai-${var.company_abbreviation}-${var.project_name}-${var.environment}-key-vault-secrets-officer"
  location            = var.location
  resource_group_name = module.resource_group_data.resource_group_name
  tags                = local.tags
}

module "user_assigned_identity_adf_contributor" {
  count = var.include_data_factory ? 1 : 0

  source              = "./modules/user_assigned_identity"
  name                = "uai-${var.company_abbreviation}-${var.project_name}-${var.environment}-adf-contributor"
  location            = var.location
  resource_group_name = module.resource_group_data.resource_group_name
  tags                = local.tags
}

module "user_assigned_identity_sql_server_contributor" {
  count = var.include_sql_database ? 1 : 0

  source              = "./modules/user_assigned_identity"
  name                = "uai-${var.company_abbreviation}-${var.project_name}-${var.environment}-sql-server-contributor"
  location            = var.location
  resource_group_name = module.resource_group_data.resource_group_name
  tags                = local.tags
}

locals {
  uai_dls_data_contributor_id           = var.include_storage_account ? module.user_assigned_identity_dls_data_contributor[0].id : ""
  uai_dls_data_contributor_principal_id = var.include_storage_account ? module.user_assigned_identity_dls_data_contributor[0].principal_id : ""

  uai_key_vault_secrets_officer_id           = module.user_assigned_identity_key_vault_secrets_officer.id
  uai_key_vault_secrets_officer_principal_id = module.user_assigned_identity_key_vault_secrets_officer.principal_id

  uai_adf_contributor_id           = var.include_data_factory ? module.user_assigned_identity_adf_contributor[0].id : ""
  uai_adf_contributor_principal_id = var.include_data_factory ? module.user_assigned_identity_adf_contributor[0].principal_id : ""

  uai_sql_server_contributor_id           = var.include_sql_database ? module.user_assigned_identity_sql_server_contributor[0].id : ""
  uai_sql_server_contributor_principal_id = var.include_sql_database ? module.user_assigned_identity_sql_server_contributor[0].principal_id : ""
}

#################################################
################ STORAGE ACCOUNT ################
#################################################
module "storage_account" {
  count = var.include_storage_account ? 1 : 0

  source                   = "./modules/storage_account"
  name                     = "dls${var.company_abbreviation}${var.project_name}${var.environment}"
  location                 = var.location
  resource_group_name      = module.resource_group_data.resource_group_name
  environment              = var.environment
  account_replication_type = var.storage_account_account_replication_type

  include_networking             = var.include_networking
  networking_resource_group_name = var.networking_resource_group_name
  vnet_id                        = local.vnet_id
  data_platform_subnet_id        = local.data_platform_subnet_id
  pep_dfs_ip                     = var.pep_storage_account_dfs_ip
  pep_blob_ip                    = var.pep_storage_account_blob_ip

  tags = local.tags
}

locals {
  storage_account_id   = var.include_storage_account ? module.storage_account[0].id : ""
  storage_account_name = var.include_storage_account ? module.storage_account[0].name : ""
}

##############################################
################ DATA FACTORY ################
##############################################
module "data_factory" {
  count = var.include_data_factory ? 1 : 0

  source              = "./modules/data_factory"
  name                = "adf-${var.company_abbreviation}-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = module.resource_group_data.resource_group_name

  # When the uai does not exist, the id is "". compact() takes a list and removes empty strings.
  user_assigned_identity_ids = compact([
    local.uai_dls_data_contributor_id,
    local.uai_key_vault_secrets_officer_id
  ])


  include_networking             = var.include_networking
  networking_resource_group_name = var.networking_resource_group_name
  environment                    = var.environment
  vnet_id                        = local.vnet_id
  data_platform_subnet_id        = local.data_platform_subnet_id
  pep_datafactory_ip             = var.pep_datafactory_ip
  pep_portal_ip                  = var.pep_datafactory_portal_ip

  key_vault_id = local.key_vault_id
  uai_key_vault_secrets_officer_uai_id = local.uai_key_vault_secrets_officer_id

  create_dbr_linked_service = var.include_databricks
  databricks_workspace_url  = local.databricks_workspace_url
  cluster_id                = local.databricks_adf_cluster_id

  tags = local.tags
}

locals {
  data_factory_id = var.include_data_factory ? module.data_factory[0].id : ""
  data_factory_principal_id = var.include_data_factory ? module.data_factory[0].principal_id : ""
}

###########################################
################ KEY VAULT ################
###########################################
module "key_vault" {
  source              = "./modules/key_vault"
  name                = "kv-${var.company_abbreviation}-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = module.resource_group_data.resource_group_name

  tenant_id = var.tenant_id

  include_networking             = var.include_networking
  networking_resource_group_name = var.networking_resource_group_name
  environment                    = var.environment
  vnet_id                        = local.vnet_id
  data_platform_subnet_id        = local.data_platform_subnet_id
  pep_vault_ip                   = var.pep_key_vault_vault_ip

  tags = local.tags
}

locals {
  key_vault_id = module.key_vault.id
}

############################################
################ DATABRICKS ################
############################################
module "databricks" {
  count = var.include_databricks ? 1 : 0

  source               = "./modules/databricks"
  company_abbreviation = var.company_abbreviation
  project_name         = var.project_name
  environment          = var.environment
  location             = var.location
  resource_group_name  = module.resource_group_data.resource_group_name

  include_networking             = var.include_networking
  networking_resource_group_name = var.networking_resource_group_name
  vnet_id                        = local.vnet_id
  vnet_name                      = var.vnet_name
  data_platform_subnet_id        = local.data_platform_subnet_id
  public_network_cidr_block      = var.databricks_public_subnet_cidr_block
  private_network_cidr_block     = var.databricks_private_subnet_cidr_block
  pep_ui_api_ip                  = var.pep_databricks_ui_api_ip
  pep_browser_authentication_ips = var.pep_databricks_browser_authentication_ips

  devops_agent_ip          = var.devops_agent_ip
  uc_metastore_id          = var.databricks_uc_metastore_id
  schema_names             = var.databricks_schema_names
  add_storage_credential   = var.include_storage_account && var.databricks_uc_metastore_id != ""
  dls_storage_account_name = local.storage_account_name

  first_environment = var.first_environment

  create_cluster = var.include_data_factory

  tags = local.tags

  depends_on = [module.storage_account]
}

locals {
  databricks_host                          = var.include_databricks ? module.databricks[0].host : ""
  databricks_access_connector_principal_id = var.include_databricks ? module.databricks[0].access_connector_principal_id : ""
  databricks_access_connector_id           = var.include_databricks ? module.databricks[0].access_connector_id : ""
  databricks_workspace_id                  = var.include_databricks ? module.databricks[0].workspace_id : ""
  databricks_workspace_url                 = var.include_databricks ? module.databricks[0].workspace_url : ""
  databricks_adf_cluster_id                = var.include_databricks ? module.databricks[0].adf_cluster_id : ""
}

# Give terraform user rights to create Key Vault Secret
resource "azurerm_role_assignment" "user_secret_officer" {
  principal_id = data.azurerm_client_config.current.object_id
  role_definition_name = "Key Vault Secrets Officer"
  scope = local.key_vault_id
}

# Save databricks token in Key Vault
resource "azurerm_key_vault_secret" "databricks_token" {
  count = var.include_databricks ? 1 : 0

  name         = "databricks-token"
  value        = module.databricks[0].token
  key_vault_id = module.key_vault.id

  depends_on = [ azurerm_role_assignment.user_secret_officer ]
}

###########################################
################ EVENT HUB ################
###########################################
module "event_hub" {
  count = var.include_eventhub ? 1 : 0

  source                   = "./modules/event_hub"
  namespace_name           = "evhns-${var.company_abbreviation}-${var.project_name}-${var.environment}"
  location                 = var.location
  resource_group_name      = module.resource_group_data.resource_group_name
  sku                      = var.event_hub_namespace_sku
  capacity                 = var.event_hub_namespace_capacity
  auto_inflate_enabled     = var.event_hub_namespace_auto_inflate
  maximum_throughput_units = var.event_hub_namespace_maximum_throughput_units

  user_assigned_identity_ids = compact([
    local.uai_dls_data_contributor_id
  ])

  event_hub_name              = "evh-${var.company_abbreviation}-${var.project_name}-${var.environment}"
  partition_count             = var.event_hub_partition_count
  message_retention           = var.event_hub_message_retention
  enable_data_capture         = var.event_hub_enable_data_capture
  capture_interval            = var.event_hub_capture_interval
  capture_storage_account_id  = local.storage_account_id
  capture_blob_container_name = "bronze"

  include_networking             = var.include_networking
  environment                    = var.environment
  networking_resource_group_name = var.networking_resource_group_name
  data_platform_subnet_id        = local.data_platform_subnet_id
  vnet_id                        = local.vnet_id
  pep_namespace_ip               = var.pep_event_hub_namespace_ip

  tags = local.tags
}

################################################
################ AZURE FUNCTION ################
################################################
module "azure_function" {
  count = var.include_azure_function ? 1 : 0

  source               = "./modules/function_app"
  name                 = "func-${var.company_abbreviation}-${var.project_name}-${var.environment}"
  location             = var.location
  resource_group_name  = module.resource_group_data.resource_group_name
  storage_account_name = "stfunc${var.project_name}${var.environment}"
  kind                 = var.azure_function_kind
  sku_name             = var.azure_function_sku_name
  runtime              = var.azure_function_runtime

  user_assigned_identity_ids = compact([
    local.uai_key_vault_secrets_officer_id,
    local.uai_dls_data_contributor_id,
    local.uai_adf_contributor_id,
    local.uai_sql_server_contributor_id
  ])

  include_networking               = var.include_networking
  environment                      = var.environment
  networking_resource_group_name   = var.networking_resource_group_name
  data_platform_subnet_id          = local.data_platform_subnet_id
  vnet_id                          = local.vnet_id
  pep_sites_ip                     = var.pep_function_sites_ip
  data_platform_subnet_cidr_block  = var.data_platform_subnet_cidr_block
  vnet_name                        = var.vnet_name
  azure_function_subnet_cidr_block = var.azure_function_subnet_cidr_block
  data_platform_nsg_name           = local.nsg_data_platform_name

  tags = local.tags
}

##############################################
################ SQL DATABASE ################
##############################################
locals {
  sql_database_sku_name = var.sql_database_type == "DTU" ? var.sql_database_dtu_sku : lookup({
    "General Purpose" = "GP_Gen5_${var.sql_database_vcpu_count}",
    "Hyperscale"      = "HS_Gen5_${var.sql_database_vcpu_count}"
  })
}
module "sql_database" {
  count = var.include_sql_database ? 1 : 0

  source              = "./modules/sql_db"
  location            = var.location
  resource_group_name = module.resource_group_data.resource_group_name
  server_name         = "sql-${var.company_abbreviation}-${var.project_name}-${var.environment}"
  server_version      = var.sql_server_version
  login_username      = var.sql_server_admin_login_username
  tenant_id           = var.tenant_id
  object_id           = var.sql_server_admin_object_id

  database_name         = "sqldb-${var.company_abbreviation}-${var.project_name}-${var.environment}"
  database_license_type = var.sql_database_license_type
  database_sku_name     = local.sql_database_sku_name
  database_max_size_gb  = var.sql_database_max_size_gb

  include_networking             = var.include_networking
  environment                    = var.environment
  networking_resource_group_name = var.networking_resource_group_name
  vnet_id                        = local.vnet_id
  pep_sqlserver_ip               = var.pep_sqlserver_ip
  data_platform_subnet_id        = local.data_platform_subnet_id

  tags = local.tags
}

locals {
  sql_server_id = var.include_sql_database ? module.sql_database[0].sql_server_id : ""
}

##################################################
################ ROLE ASSIGNMENTS ################
##################################################
module "role_assignment" {
  source = "./modules/role_assignment"
  role_definition_list = [
    {
      create               = var.include_storage_account
      principal_id         = local.uai_dls_data_contributor_principal_id
      role_definition_name = "Storage Blob Data Contributor"
      scope                = local.storage_account_id
    },
    {
      create               = true
      principal_id         = local.uai_key_vault_secrets_officer_principal_id
      role_definition_name = "Key Vault Secrets Officer"
      scope                = local.key_vault_id
    },
    {
      create = var.include_data_factory
      principal_id = local.data_factory_principal_id
      role_definition_name = "Key Vault Secrets User"
      scope = local.key_vault_id
    },
    {
      create               = var.include_data_factory
      principal_id         = local.uai_adf_contributor_principal_id
      role_definition_name = "Contributor"
      scope                = local.data_factory_id
    },
    {
      create               = var.include_sql_database
      principal_id         = local.uai_sql_server_contributor_principal_id
      role_definition_name = "Contributor"
      scope                = local.sql_server_id
    },
    {
      create               = var.include_storage_account && var.include_databricks
      principal_id         = local.databricks_access_connector_principal_id
      role_definition_name = "Storage Blob Data Contributor"
      scope                = local.storage_account_id
    },
    {
      create               = var.include_sql_database && var.include_databricks
      principal_id         = local.databricks_access_connector_principal_id
      role_definition_name = "Contributor"
      scope                = local.sql_server_id
    }
  ]
}
