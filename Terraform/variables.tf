###################################################
################ GENERAL VARIABLES ################
###################################################
variable "tenant_id" {
  description = "The id of the Azure tenant where this solution will be deployed."
  type        = string
}

variable "subscription_id" {
  description = "The id of the Subscription where the resources will be deployed to."
  type        = string
}

variable "owner" {
  description = "The name of the resource owner. Used for tags."
  type        = string
}

variable "company_abbreviation" {
  description = "The abbreviation of the company name. Will be used to name the different resources."
  type        = string
}

variable "project_name" {
  description = "The name of the project. Will be used to name the different resources."
  type        = string
}

variable "project_tag_name" {
  description = "The name of the project to populate the tag, does not need to be abbreviated."
  type        = string
}

variable "environment" {
  description = "The name of the environment. (e.g. dev, prod ...)"
  type        = string
}

variable "location" {
  description = "The location where the resources will be deployed to. Defaults to \"West Europe\"."
  type        = string
  default     = "West Europe"
}

variable "devops_agent_ip" {
  description = "The IP Address of the DevOps Agent."
  type        = string
  default     = ""

  validation {
    condition     = !(var.include_networking && var.databricks_uc_metastore_id != "" && var.devops_agent_ip == "")
    error_message = "Variable 'devops_agent_ip' cannot be empty when 'include_networking' is true and 'databricks_uc_metastore_id' is filled in."
  }
}

####################################################
################ RESOURCE VARIABLES ################
####################################################

########## STORAGE ACCOUNT
variable "include_storage_account" {
  description = "Whether or not to include a Storage Account."
  type        = bool
  default     = false
}

variable "storage_account_account_replication_type" {
  description = "The type of replication to use for the storage account."
  type        = string
  default     = "LRS"
}

########## DATA FACTORY
variable "include_data_factory" {
  description = "Whether or not to include Data Factory."
  type        = bool
  default     = false
}

########## DATABRICKS
variable "include_databricks" {
  description = "Whether or not to include Databricks."
  type        = bool
  default     = false
}

variable "databricks_uc_metastore_id" {
  description = "The ID of the Unity Catalog metastore."
  type        = string
  default     = ""
}

variable "first_environment" {
  description = "Whether or not you are deploying the first environment."
  type        = bool
  default     = false
}

variable "databricks_schema_names" {
  description = "A list of schema names to create in this environments Databricks catalog."
  type        = list(string)
  default     = ["bronze", "silver", "gold"]
}

variable "databricks_account_id" {
  description = "The id of your Databricks account."
  type        = string
  default     = ""

  validation {
    condition     = !(var.include_databricks && var.databricks_uc_metastore_id != "" && var.databricks_account_id == "")
    error_message = "Variable 'databricks_account_id' should be filled in when 'include_databricks' is true and 'databricks_uc_metastore_id' is filled in."
  }
}

########## EVENT HUB
variable "include_eventhub" {
  description = "Whether or not to include an Event Hub."
  type        = bool
  default     = false
}

variable "event_hub_namespace_sku" {
  description = "Which tier to use for the Event Hub."
  type        = string
  default     = "Standard"

  validation {
    condition     = var.event_hub_namespace_sku == "Standard" || var.event_hub_namespace_sku == "Premium"
    error_message = "The 'event_hub_sku' should be 'Standard' or 'Premium'."
  }
}

variable "event_hub_namespace_auto_inflate" {
  description = "Whether or not to enable auto inflate in the Event Hub."
  type        = bool
  default     = true
}

variable "event_hub_namespace_capacity" {
  description = "The capacity / troughput units for a Standard SKU namespace."
  type        = number
  default     = 2
}

variable "event_hub_namespace_maximum_throughput_units" {
  description = "The maximum capacity / throughput units that the Event Hub can scale to."
  type        = number
  default     = 4

  validation {
    condition     = !(var.event_hub_namespace_auto_inflate && var.event_hub_namespace_maximum_throughput_units == null)
    error_message = "Variable 'event_hub_namespace_maximum_throughput_units' needs to be filled in when 'event_hub_namespace_auto_inflate' is true."
  }

  validation {
    condition     = !(var.event_hub_namespace_capacity > var.event_hub_namespace_maximum_throughput_units)
    error_message = "Value of variable 'event_hub_namespace_maximum_throughput_units' needs to be bigger than the value of 'event_hub_namespace_capacity'."
  }
}

variable "event_hub_partition_count" {
  description = "The number of shards on the Event Hub."
  type        = number
  default     = 1
}

variable "event_hub_message_retention" {
  description = "The number of days to retain events in the Event Hub."
  type        = number
  default     = 1
}

variable "event_hub_enable_data_capture" {
  description = "Whether or not to enable data capture for the Event Hub."
  type        = bool
  default     = true
}

variable "event_hub_capture_interval" {
  description = "The time interval in seconds at which the capture of the Event Hub will happen."
  type        = number
  default     = 300
}

########## AZURE FUNCTION
variable "include_azure_function" {
  description = "Whether or not to include an Azure Function."
  type        = bool
  default     = false
}

variable "azure_function_kind" {
  description = "The kind of the Function App."
  type        = string
  default     = "ASP"

  validation {
    condition     = var.azure_function_kind == "ASP" || var.azure_function_kind == "Consumption"
    error_message = "The kind should be 'ASP' or 'Consumption'."
  }

  validation {
    condition     = !(var.azure_function_kind == "Consumption" && var.include_networking)
    error_message = "Please change the variable 'azure_function_kind', or disable networking, since a consumption plan does not support networking."
  }
}

variable "azure_function_sku_name" {
  description = "The SKU name for the Function App's Service Plan."
  type        = string
  default     = "B1"

  validation {
    condition     = !(var.azure_function_kind == "ASP" && contains(["Y1", "FC1", "EP1", "EP2", "EP3"], var.azure_function_sku_name))
    error_message = "Variable 'azure_function_sku_name' must be one of: B1, B2, B3, D1, F1, P1v2, P2v2, P3v2, P0v3, P1v3, P2v3, P3v3, P1mv3, P2mv3, P3mv3, P4mv3, P5mv3, S1, S2, S3, SHARED, WS1, WS2, WS3 when 'azure_function_kind' is 'ASP'."
  }

  validation {
    condition = !(var.azure_function_kind == "Consumption" && contains([
      "B1", "B2", "B3", "D1", "F1", "P1v2", "P2v2", "P3v2",
      "P0v3", "P1v3", "P2v3", "P3v3", "P1mv3", "P2mv3", "P3mv3",
      "P4mv3", "P5mv3", "S1", "S2", "S3", "SHARED", "WS1", "WS2", "WS3"
    ], var.azure_function_sku_name))
    error_message = "Variable 'azure_function_sku_name' must be one of: Y1, FC1, EP1, EP2, EP3 when 'azure_function_kind' is 'Consumption'."
  }
}

variable "azure_function_runtime" {
  description = "The runtime that the Function should use."

  type = object({
    language = string
    version  = string
  })

  default = {
    language = "Python"
    version  = "3.11"
  }

  validation {
    condition     = contains(["Python", ".NET", "Java", "JavaScript", "PowerShell"], var.azure_function_runtime.language)
    error_message = "Variable 'azure_function_runtime.language' must be one of: Python, .NET, Java, JavaScript, or PowerShell."
  }

  validation {
    condition = (
      (var.azure_function_runtime.language == "Python" && contains(["3.7", "3.8", "3.9", "3.10", "3.11", "3.12"], var.azure_function_runtime.version)) ||
      (var.azure_function_runtime.language == ".NET" && contains(["3.1", "6.0", "7.0", "8.0", "9.0"], var.azure_function_runtime.version)) ||
      (var.azure_function_runtime.language == "Java" && contains(["8", "11", "17", "21"], var.azure_function_runtime.version)) ||
      (var.azure_function_runtime.language == "JavaScript" && contains(["12", "14", "16", "18", "20", "22"], var.azure_function_runtime.version)) ||
      (var.azure_function_runtime.language == "PowerShell" && contains(["7", "7.2", "7.4"], var.azure_function_runtime.version))
    )
    error_message = "Invalid version ('azure_function_runtime.version') for the selected language. Allowed versions: Python (3.7-3.12), .NET (3.1, 6.0, 7.0, 8.0, 9.0), Java (8, 11, 17, 21), JavaScript (12, 14, 16, 18, 20, 22), PowerShell (7, 7.2, 7.4)."
  }
}

########## SQL DATABASE
variable "include_sql_database" {
  description = "Whether or not to include a SQL database."
  type        = bool
  default     = false
}

variable "sql_server_version" {
  description = "The version for the SQL server."
  type        = string
  default     = "12.0"

  validation {
    condition     = contains(["2.0", "12.0"], var.sql_server_version)
    error_message = "Error in variable 'sql_server_version' valid values are: 2.0 (for v11 server) and 12.0 (for v12 server)."
  }
}

variable "sql_server_admin_login_username" {
  description = "The login username of the Azure AD Administrator for the SQL Server."
  type        = string
  default     = ""

  validation {
    condition     = !(var.include_sql_database && var.sql_server_admin_login_username == "")
    error_message = "Variable 'sql_server_login_username' cannot be empty when 'include_sql_database' is true."
  }
}

variable "sql_server_admin_object_id" {
  description = "The object id in EntraID of the administrator for the SQL Server."
  type        = string
  default     = ""

  validation {
    condition     = !(var.include_sql_database && var.sql_server_admin_object_id == "")
    error_message = "Variable 'sql_server_admin_object_id' cannot be empty when 'include_sql_database' is true."
  }
}

variable "sql_database_license_type" {
  description = "The type of license for the SQL database."
  type        = string
  default     = "LicenseIncluded"

  validation {
    condition     = contains(["LicenseIncluded", "BasePrice"], var.sql_database_license_type)
    error_message = "Variable 'sql_database_license_type' can only be 'LicenseIncluded' or 'BasePrice'."
  }
}

variable "sql_database_type" {
  description = "The type of the SQL databases compute."
  type        = string
  default     = "DTU"

  validation {
    condition     = contains(["DTU", "General Purpose", "Hyperscale"], var.sql_database_type)
    error_message = "Variable 'sql_database_type' can only be 'DTU', 'General Purpose' or 'Hypersclae'."
  }
}

variable "sql_database_dtu_sku" {
  description = "The DTU sku for the SQL database sku."
  type        = string
  default     = "Basic"

  validation {
    condition = contains([
      "Basic",
      "S0", "S1", "S2", "S3", "S4", "S6", "S7", "S9", "S12",
      "P1", "P2", "P4", "P6", "P11", "P15"
    ], var.sql_database_dtu_sku)
    error_message = "Variable 'sql_database_dtu_sku' has an invalid SKU: '${var.sql_database_dtu_sku}'. Allowed values are: Basic, S0, S1, S2, S3, S4, S6, S7, S9, S12, P1, P2, P4, P6, P11, P15."
  }
}

variable "sql_database_vcpu_count" {
  description = "The amount of VCPUs for the SQL database sku. Has no impact when DTU type is seleceted."
  type        = number
  default     = 2

  validation {
    condition = var.sql_database_type != "General Purpose" || contains([
      2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 24, 32, 40, 80, 128
    ], var.sql_database_vcpu_count)
    error_message = "Variable 'sql_database_vcpu_count' '${var.sql_database_vcpu_count}' is invalid for General Purpose SKU. Allowed values: 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 24, 32, 40, 80, 128."
  }

  validation {
    condition = var.sql_database_type != "Hyperscale" || contains([
      2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 24, 32, 40, 80
    ], var.sql_database_vcpu_count)
    error_message = "Variable 'sql_database_vcpu_count' '${var.sql_database_vcpu_count}' is invalid for Hyperscale SKU. Allowed values: 2, 4, 6, 8, 10, 12, 14, 16, 18, 20, 24, 32, 40, 80."
  }
}

variable "sql_database_max_size_gb" {
  description = "The max size in GB that the SQL database can grow to."
  type        = number
  default     = 2
}

######################################################
################ NETWORKING VARIABLES ################
######################################################

########## GENERAL
variable "networking_resource_group_name" {
  description = "The name of the resource group for the networking components."
  type        = string
  default     = ""

  validation {
    condition     = !(var.include_networking && var.networking_resource_group_name == "")
    error_message = "Variable 'networking_resource_group_name' cannot be empty when 'include_networking' is true."
  }
}

variable "vnet_name" {
  description = "The name of the vnet."
  type        = string
  default     = ""

  validation {
    condition     = !(var.include_networking && var.vnet_name == "")
    error_message = "Variable 'vnet_name' cannot be empty when 'include_networking' is true."
  }
}

variable "include_networking" {
  description = "Whether or not to include networking resources."
  type        = bool
  default     = false
}

########## VPN CONNECTION
variable "include_vpn_connection" {
  description = "Whether or not to include the ability to connect trough Azure VPN."
  type        = bool
  default     = false

  validation {
    condition     = !(var.include_networking == false && var.include_vpn_connection)
    error_message = "Variable 'include_vpn_connection' cannot be true when 'include_networking' is false."
  }
}

variable "vpn_application_id" {
  description = "The application id of the Azure VPN in Entra ID."
  type        = string
  default     = ""

  validation {
    condition     = !(var.include_vpn_connection && var.vpn_application_id == "")
    error_message = "Variable 'vpn_application_id' cannot be empty when 'include_vpn_connection' is true."
  }
}

########## VM CONNECTION
variable "include_vm_connection" {
  description = "Whether or not to include the ability to connect trough a VM."
  type        = bool
  default     = false

  validation {
    condition     = !(var.include_networking == false && var.include_vm_connection)
    error_message = "Variable 'include_vm_connection' cannot be true when 'include_networking' is false."
  }
}

variable "vm_admin_username" {
  description = "The admin username for the VM used for development."
  type        = string
  default     = ""

  validation {
    condition     = !(var.include_vm_connection && var.vm_admin_username == "")
    error_message = "Variable 'vm_admin_username' cannot be empty when 'include_vm_connection' is true."
  }
}

variable "vm_admin_password" {
  description = "The password for the admin account on the VM used for development."
  type        = string
  default     = ""

  validation {
    condition     = !(var.include_vm_connection && var.vm_admin_password == "")
    error_message = "Variable 'vm_admin_password' cannot be empty when 'include_vm_connection' is true."
  }
}

variable "vm_private_ip" {
  description = "The private ip address that will be given to the VM used for development."
  type        = string
  default     = "10.0.5.100"
}

variable "vm_size" {
  description = "The size of the VM used for development."
  type        = string
  default     = "Standard_D2s_v3"
}

variable "vm_source_image_reference" {
  description = "The source image reference for the Windows VM's OS."

  type = object({
    publisher = string
    offer     = string
    sku       = string
    version   = string
  })

  default = {
    publisher = "MicrosoftWindowsDesktop"
    offer     = "windows-11"
    sku       = "win11-22h2-ent"
    version   = "latest"
  }
}

########## SUBNETS - CIDR BLOCKS
variable "gateway_subnet_cidr_block" {
  description = "The CIDR block to be given to the GatewaySubnet."
  type        = string
  default     = "10.0.1.0/24"
}

variable "vpn_configuration_address_space_cidr_block" {
  description = "The address space that can be occupied by VPN connections."
  type        = string
  default     = "172.16.201.0/24"
}

variable "databricks_public_subnet_cidr_block" {
  description = "The CIDR block to be given to the Databricks public subnet."
  type        = string
  default     = "10.0.2.0/24"
}

variable "databricks_private_subnet_cidr_block" {
  description = "The CIDR block to be given to the Databricks private subnet."
  type        = string
  default     = "10.0.3.0/24"
}

variable "azure_function_subnet_cidr_block" {
  description = "The CIDR block to be given to the azure-function subnet."
  type        = string
  default     = "10.0.4.0/24"
}

variable "data_platform_subnet_cidr_block" {
  description = "The CIDR block to be given to the data-platform subnet."
  type        = string
  default     = "10.0.5.0/24"
}

########## PRIVATE ENDPOINTS - IP ADDRESSES
variable "pep_databricks_ui_api_ip" {
  description = "The ip address that will be given to the databricks ui api private endpoint."
  type        = string
  default     = "10.0.5.10"
}

variable "pep_databricks_browser_authentication_ips" {
  description = "The ip addresses that will be given to the databricks browser authentication private endpoint."
  type        = list(string)
  default     = ["10.0.5.11", "10.0.5.12", "10.0.5.13"]

  validation {
    condition     = length(var.pep_databricks_browser_authentication_ips) == 3
    error_message = "pep_databricks_browser_authentication_ips must contain exactly 3 ip addresses."
  }
}

variable "pep_datafactory_ip" {
  description = "The ip address that will be given to the datafactory private endpoint."
  type        = string
  default     = "10.0.5.20"
}

variable "pep_datafactory_portal_ip" {
  description = "The ip address that will be given to the datafactory portal private endpoint."
  type        = string
  default     = "10.0.5.21"
}

variable "pep_storage_account_dfs_ip" {
  description = "The ip address that will be given to the storage account dfs private endpoint."
  type        = string
  default     = "10.0.5.30"
}

variable "pep_storage_account_blob_ip" {
  description = "The ip address that will be given to the storage account blob private endpoint."
  type        = string
  default     = "10.0.5.31"
}

variable "pep_key_vault_vault_ip" {
  description = "The ip address that will be given to the key vault vault private endpoint."
  type        = string
  default     = "10.0.5.40"
}

variable "pep_event_hub_namespace_ip" {
  description = "The ip address that will be given to the event hub namespace private endpoint."
  type        = string
  default     = "10.0.5.50"
}

variable "pep_function_sites_ip" {
  description = "The ip address that will be given to the azure function sites private endpoint."
  type        = string
  default     = "10.0.5.60"
}

variable "pep_sqlserver_ip" {
  description = "The ip address that will be given to the sqlserver private endpoint."
  type        = string
  default     = "10.0.5.70"
}
