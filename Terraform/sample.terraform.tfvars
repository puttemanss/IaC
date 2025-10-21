###### Optional variables are commented out, default values are filled in. ######

###################################################
################ GENERAL VARIABLES ################
###################################################

tenant_id            = ""
subscription_id      = ""
owner                = ""
company_abbreviation = ""
project_name         = ""
project_tag_name     = ""
environment          = ""
# location             = "West Europe"

####################################################
################ RESOURCE VARIABLES ################
####################################################

########## STORAGE ACCOUNT
# include_storage_account                  = false
# storage_account_account_replication_type = "LRS"

########## DATA FACTORY
# include_data_factory = false

########## DATABRICKS
# include_databricks         = false
# databricks_uc_metastore_id = ""
# first_environment    = false
# databricks_schema_names    = ["bronze", "silver", "gold"]
# databricks_account_id      = ""

########## EVENT HUB
# include_event_hub                           = false
# event_hub_namespace_sku                     = "Standard"
# event_hub_namespace_auto_inflate            = true
# event_hub_namespace_capacity                = 2
# event_hub_namespace_maximum_througput_units = 4
# event_hub_partition_count                   = 1
# event_hub_message_retention                 = 1
# event_hub_enable_data_capture               = true
# event_hub_capture_interval                  = 300

########## AZURE FUNCTION
# include_azure_function  = false
# azure_function_kind     = "Consumption"
# azure_function_sku_name = "Y1"
# azure_function_runtime = {
#   language = "Python"
#   version  = "3.11"
# }

########## SQL DATABASE
# include_sql_database            = false
# sql_server_version              = "12.0"
# sql_server_admin_login_username = ""
# sql_server_admin_object_id      = ""
# sql_database_license_type       = "LicenseIncluded"
# sql_database_type               = "DTU"
# sql_database_dtu_sku            = "Basic"
# sql_database_vcpu_count         = 2
# sql_database_max_size_gb        = 2
# sql_database_prevent_destroy    = true

######################################################
################ NETWORKING VARIABLES ################
######################################################

########## GENERAL
# include_networking             = false
# networking_resource_group_name = "" # fill in if include_networking is true
# vnet_name                      = "" # fill in if include_networking is true

########## VPN CONNECTION
# include_vpn_connection = false # can only be true if include_networking is true
# vpn_application_id     = ""    # fill in if include_vpn_connection is true

########## VM CONNECTION
# include_vm_connection = false # can only be true if include_networking is true
# vm_admin_username     = ""    # fill in if include_vm_connection is true
# vm_admin_password     = ""    # fill in if include_vm_connection is true
# vm_private_ip         = "10.0.5.100"

########## SUBNETS - CIDR BLOCKS
# gateway_subnet_cidr_block                  = "10.0.1.0/24"
# vpn_configuration_address_space_cidr_block = "172.16.201.0/24"
# databricks_public_subnet_cidr_block        = "10.0.2.0/24"
# databricks_private_subnet_cidr_block       = "10.0.3.0/24"
# azure_function_subnet_cidr_block           = "10.0.4.0/24"
# data_platform_subnet_cidr_block            = "10.0.5.0/24"

########## PRIVATE ENDPOINTS - IP ADDRESSES
# pep_databricks_ui_api_ip                  = "10.0.5.10"
# pep_databricks_browser_authentication_ips = ["10.0.5.11", "10.0.5.12", "10.0.5.13"]
# pep_datafactory_ip                        = "10.0.5.20"
# pep_datafactory_portal_ip                 = "10.0.5.21"
# pep_storage_account_dfs_ip                = "10.0.5.30"
# pep_storage_account_blob_ip               = "10.0.5.31"
# pep_key_vault_vault_ip                    = "10.0.5.40"
# pep_event_hub_namespace_ip                = "10.0.5.50"
# pep_function_sites_ip                     = "10.0.5.60"
# pep_sqlserver_ip                          = "10.0.5.70"
