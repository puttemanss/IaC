locals {
  metastore_privileges          = ["CREATE_CATALOG", "CREATE_CLEAN_ROOM", "CREATE_CONNECTION", "CREATE_EXTERNAL_LOCATION", "CREATE_PROVIDER", "CREATE_RECIPIENT", "CREATE_SHARE", "CREATE_SERVICE_CREDENTIAL", "CREATE_STORAGE_CREDENTIAL", "SET_SHARE_PERMISSION", "USE_MARKETPLACE_ASSETS", "USE_PROVIDER", "USE_RECIPIENT", "USE_SHARE"]
  catalog_privileges            = ["ALL_PRIVILEGES"]
  schema_privileges             = ["ALL_PRIVILEGES"]
  storage_credential_privileges = ["ALL_PRIVILEGES"]
  external_location_privileges  = ["ALL_PRIVILEGES"]

  unity_catalog_admins = "unity_catalog_admins" # Group name set in main.tf of unity-catalog
  data_engineers       = "data_engineers"       # Group name set in main.tf of unity-catalog
}

#########################################
################ SUBNETS ################
#########################################
locals {
  delegation_actions = [
    "Microsoft.Network/virtualNetworks/subnets/action",
    "Microsoft.Network/virtualNetworks/subnets/join/action",
    "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
    "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
  ]
}

resource "azurerm_network_security_group" "databricks_nsg" {
  count = var.include_networking ? 1 : 0

  name                = "nsg-dbr-${var.company_abbreviation}-${var.project_name}-${var.environment}"
  location            = var.location
  resource_group_name = var.networking_resource_group_name
  tags                = var.tags
}

locals {
  databricks_nsg_id   = var.include_networking ? azurerm_network_security_group.databricks_nsg[0].id : ""
  databricks_nsg_name = var.include_networking ? azurerm_network_security_group.databricks_nsg[0].name : ""
}

resource "azurerm_network_security_rule" "allow_devops_agent" {
  count = var.include_networking ? 1 : 0

  network_security_group_name = local.databricks_nsg_name
  resource_group_name         = var.networking_resource_group_name

  name                       = "DevOps-Agent"
  priority                   = 200
  direction                  = "Inbound"
  access                     = "Allow"
  protocol                   = "Tcp"
  source_address_prefix      = var.devops_agent_ip
  source_port_range          = "*"
  destination_port_range     = "*"
  destination_address_prefix = "*"
}

resource "azurerm_subnet" "subnet_host" {
  count = var.include_networking ? 1 : 0

  name                 = "snet-dbr-host-${var.environment}"
  resource_group_name  = var.networking_resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.public_network_cidr_block]

  delegation {
    name = "databricks-public-delegation"
    service_delegation {
      name    = "Microsoft.Databricks/workspaces"
      actions = local.delegation_actions
    }
  }
}

resource "azurerm_subnet" "subnet_container" {
  count = var.include_networking ? 1 : 0

  name                 = "snet-dbr-container-${var.environment}"
  resource_group_name  = var.networking_resource_group_name
  virtual_network_name = var.vnet_name
  address_prefixes     = [var.private_network_cidr_block]

  delegation {
    name = "databricks-private-delegation"
    service_delegation {
      name    = "Microsoft.Databricks/workspaces"
      actions = local.delegation_actions
    }
  }
}

locals {
  databricks_public_subnet_id    = var.include_networking ? azurerm_subnet.subnet_host[0].id : ""
  databricks_public_subnet_name  = var.include_networking ? azurerm_subnet.subnet_host[0].name : ""
  databricks_private_subnet_id   = var.include_networking ? azurerm_subnet.subnet_container[0].id : ""
  databricks_private_subnet_name = var.include_networking ? azurerm_subnet.subnet_container[0].name : ""
}

resource "azurerm_subnet_network_security_group_association" "nsg_public_subnet" {
  count = var.include_networking ? 1 : 0

  subnet_id                 = local.databricks_public_subnet_id
  network_security_group_id = local.databricks_nsg_id
}

resource "azurerm_subnet_network_security_group_association" "nsg_private_subnet" {
  count = var.include_networking ? 1 : 0

  subnet_id                 = local.databricks_private_subnet_id
  network_security_group_id = local.databricks_nsg_id
}

######################################################
################ DATABRICKS WORKSPACE ################
######################################################
resource "azurerm_databricks_workspace" "databricks_workspace" {
  name                        = "dbr-${var.company_abbreviation}-${var.project_name}-${var.environment}"
  location                    = var.location
  resource_group_name         = var.resource_group_name
  managed_resource_group_name = "rg-managed-dbr-${var.company_abbreviation}-${var.project_name}-${var.environment}"
  sku                         = "premium"

  public_network_access_enabled         = !var.include_networking
  network_security_group_rules_required = var.include_networking ? "NoAzureDatabricksRules" : null

  custom_parameters {
    storage_account_name = "dbstorage${var.project_name}${var.environment}"
    no_public_ip         = var.include_networking

    virtual_network_id  = var.include_networking ? var.vnet_id : null
    public_subnet_name  = var.include_networking ? azurerm_subnet.subnet_host[0].name : null
    private_subnet_name = var.include_networking ? azurerm_subnet.subnet_container[0].name : null

    public_subnet_network_security_group_association_id  = var.include_networking ? azurerm_subnet_network_security_group_association.nsg_public_subnet[0].id : null
    private_subnet_network_security_group_association_id = var.include_networking ? azurerm_subnet_network_security_group_association.nsg_private_subnet[0].id : null
  }
  tags = var.tags
}

data "azurerm_databricks_access_connector" "databricks_access_connector" {
  name                = "unity-catalog-access-connector"
  resource_group_name = azurerm_databricks_workspace.databricks_workspace.managed_resource_group_name

  depends_on = [
    azurerm_databricks_workspace.databricks_workspace
  ]
}

#########################################################
################ PRIVATE ENDPOINTS & DNS ################
#########################################################
module "pep_databricks_ui_api" {
  count = var.include_networking ? 1 : 0

  source                = "../private_endpoint"
  name                  = "pep-databricks-${var.environment}"
  location              = var.location
  resource_group_name   = var.networking_resource_group_name
  subnet_id             = var.data_platform_subnet_id
  private_ip_address    = var.pep_ui_api_ip
  resource_id           = azurerm_databricks_workspace.databricks_workspace.id
  resource_name         = azurerm_databricks_workspace.databricks_workspace.name
  subresource_name      = "databricks_ui_api"
  member_name           = "databricks_ui_api"
  private_dns_zone_name = "privatelink.azuredatabricks.net"
  virtual_network_id    = var.vnet_id
  tags                  = var.tags
}

locals {
  databricks_name = split(".azuredatabricks.net", azurerm_databricks_workspace.databricks_workspace.workspace_url)[0]
}

resource "azurerm_private_dns_a_record" "dbr_a_record" {
  count = var.include_networking ? 1 : 0

  name                = local.databricks_name
  zone_name           = module.pep_databricks_ui_api[0].private_dns_zone_name
  resource_group_name = var.networking_resource_group_name
  ttl                 = 10
  records             = [var.pep_ui_api_ip]
  tags                = var.tags
}

resource "azurerm_private_endpoint" "pep_browser_authentication" {
  count = var.include_networking ? 1 : 0

  name                = "pep-databricks-browser-auth-${var.environment}"
  location            = var.location
  resource_group_name = var.networking_resource_group_name
  subnet_id           = var.data_platform_subnet_id

  ip_configuration {
    name               = "west-europe-ip-config"
    private_ip_address = var.pep_browser_authentication_ips[0]
    subresource_name   = "browser_authentication"
    member_name        = "westeurope"
  }
  ip_configuration {
    name               = "west-europe-c2-ip-config"
    private_ip_address = var.pep_browser_authentication_ips[1]
    subresource_name   = "browser_authentication"
    member_name        = "westeurope-c2"
  }
  ip_configuration {
    name               = "west-europe-c3-ip-config"
    private_ip_address = var.pep_browser_authentication_ips[2]
    subresource_name   = "browser_authentication"
    member_name        = "westeurope-c3"
  }
  private_service_connection {
    name                           = "browserauth-privateserviceconnection"
    private_connection_resource_id = azurerm_databricks_workspace.databricks_workspace.id
    subresource_names              = ["browser_authentication"]
    is_manual_connection           = false
  }
  tags = var.tags
}

resource "azurerm_private_dns_a_record" "dbr_browser_auth_a_record_1" {
  count = var.include_networking ? 1 : 0

  name                = "westeurope.pl-auth"
  zone_name           = module.pep_databricks_ui_api[0].private_dns_zone_name
  resource_group_name = var.networking_resource_group_name
  ttl                 = 10
  records             = [var.pep_browser_authentication_ips[0]]
  tags                = var.tags
}

resource "azurerm_private_dns_a_record" "dbr_browser_auth_a_record_2" {
  count = var.include_networking ? 1 : 0

  name                = "westeurope-c2.pl-auth"
  zone_name           = module.pep_databricks_ui_api[0].private_dns_zone_name
  resource_group_name = var.networking_resource_group_name
  ttl                 = 10
  records             = [var.pep_browser_authentication_ips[1]]
  tags                = var.tags
}

resource "azurerm_private_dns_a_record" "dbr_browser_auth_a_record_3" {
  count = var.include_networking ? 1 : 0

  name                = "westeurope-c3.pl-auth"
  zone_name           = module.pep_databricks_ui_api[0].private_dns_zone_name
  resource_group_name = var.networking_resource_group_name
  ttl                 = 10
  records             = [var.pep_browser_authentication_ips[2]]
  tags                = var.tags
}

##########################################################
################ UNITY CATALOG CONNECTION ################
##########################################################
resource "databricks_metastore_assignment" "unity_catalog_connection" {
  count = var.uc_metastore_id == "" ? 0 : 1

  metastore_id = var.uc_metastore_id
  workspace_id = azurerm_databricks_workspace.databricks_workspace.workspace_id
}

resource "databricks_catalog" "catalog" {
  count = var.uc_metastore_id == "" ? 0 : 1

  name         = "${var.company_abbreviation}-${var.environment}"
  metastore_id = var.uc_metastore_id

  depends_on = [
    databricks_metastore_assignment.unity_catalog_connection,
    databricks_grant.metastore
  ]
}

resource "databricks_schema" "schemas" {
  for_each = var.uc_metastore_id == "" ? toset([]) : toset(var.schema_names)

  name         = each.value
  catalog_name = databricks_catalog.catalog[0].name

  depends_on = [
    databricks_catalog.catalog,
    databricks_grant.metastore
  ]
}

#########################################################################
################ STORAGE CREDENTIAL & EXTERNAL LOCATIONS ################
#########################################################################
resource "databricks_storage_credential" "storage_credential" {
  count = var.add_storage_credential ? 1 : 0

  name    = "sc-${var.company_abbreviation}-${var.project_name}-${var.environment}"
  comment = "Managed by Terrform"
  azure_managed_identity {
    access_connector_id = data.azurerm_databricks_access_connector.databricks_access_connector.id
  }
  depends_on = [
    databricks_metastore_assignment.unity_catalog_connection,
    databricks_grant.metastore,
    azurerm_network_security_rule.allow_devops_agent
  ]
}

resource "databricks_external_location" "external_location_bronze" {
  count = var.add_storage_credential ? 1 : 0

  name            = "ext-${var.company_abbreviation}-${var.project_name}-bronze"
  url             = "abfss://bronze@${var.dls_storage_account_name}.dfs.core.windows.net"
  credential_name = databricks_storage_credential.storage_credential[0].name
  comment         = "Managed by Terraform"
  depends_on = [
    databricks_metastore_assignment.unity_catalog_connection,
    databricks_grant.metastore
  ]
}

resource "databricks_external_location" "external_location_silver" {
  count = var.add_storage_credential ? 1 : 0

  name            = "ext-${var.company_abbreviation}-${var.project_name}-silver"
  url             = "abfss://silver@${var.dls_storage_account_name}.dfs.core.windows.net"
  credential_name = databricks_storage_credential.storage_credential[0].name
  comment         = "Managed by Terraform"
  depends_on = [
    databricks_metastore_assignment.unity_catalog_connection,
    databricks_grant.metastore
  ]
}

resource "databricks_external_location" "external_location_gold" {
  count = var.add_storage_credential ? 1 : 0

  name            = "ext-${var.company_abbreviation}-${var.project_name}-gold"
  url             = "abfss://gold@${var.dls_storage_account_name}.dfs.core.windows.net"
  credential_name = databricks_storage_credential.storage_credential[0].name
  comment         = "Managed by Terraform"
  depends_on = [
    databricks_metastore_assignment.unity_catalog_connection,
    databricks_grant.metastore
  ]
}

###################################################
################ DATABRICKS GRANTS ################
###################################################
resource "databricks_grant" "metastore" {
  count = var.first_environment ? 1 : 0

  metastore  = var.uc_metastore_id
  principal  = local.unity_catalog_admins
  privileges = local.metastore_privileges

  depends_on = [ databricks_metastore_assignment.unity_catalog_connection ]
}

resource "databricks_grants" "catalog_grants" {
  count = var.uc_metastore_id == "" ? 0 : 1

  catalog = databricks_catalog.catalog[0].id

  grant {
    principal  = local.unity_catalog_admins
    privileges = local.catalog_privileges
  }
  grant {
    principal  = local.data_engineers
    privileges = local.catalog_privileges
  }

  depends_on = [ databricks_metastore_assignment.unity_catalog_connection ]
}

locals {
  schemas = var.uc_metastore_id == "" ? {} : { for schema in databricks_schema.schemas : schema.name => schema }
}

resource "databricks_grants" "schema_grants" {
  for_each = local.schemas

  schema = each.value.id

  grant {
    principal  = local.unity_catalog_admins
    privileges = local.schema_privileges
  }
  grant {
    principal  = local.data_engineers
    privileges = local.schema_privileges
  }

  depends_on = [ databricks_metastore_assignment.unity_catalog_connection ]
}

resource "databricks_grants" "storage_credential_grants" {
  count = var.uc_metastore_id == "" ? 0 : 1

  storage_credential = databricks_storage_credential.storage_credential[0].id

  grant {
    principal  = local.unity_catalog_admins
    privileges = local.storage_credential_privileges
  }
  grant {
    principal  = local.data_engineers
    privileges = local.storage_credential_privileges
  }

  depends_on = [ databricks_metastore_assignment.unity_catalog_connection ]
}

locals {
  external_locations_map = var.uc_metastore_id == "" ? {} : {
    bronze = databricks_external_location.external_location_bronze[0].id,
    silver = databricks_external_location.external_location_silver[0].id,
    gold   = databricks_external_location.external_location_gold[0].id
  }
}

resource "databricks_grants" "external_location_grants" {
  for_each = local.external_locations_map

  external_location = each.value

  grant {
    principal  = local.unity_catalog_admins
    privileges = local.external_location_privileges
  }
  grant {
    principal  = local.data_engineers
    privileges = local.external_location_privileges
  }

  depends_on = [
    databricks_metastore_assignment.unity_catalog_connection,
    databricks_external_location.external_location_bronze,
    databricks_external_location.external_location_silver,
    databricks_external_location.external_location_gold
  ]
}

##################################################
################ DATABRICKS TOKEN ################
##################################################
resource "databricks_token" "token" {
  provider = databricks
  comment  = "Token for ADF. Managed by Terraform."
}

####################################################
################ DATABRICKS CLUSTER ################
####################################################
data "databricks_node_type" "smallest" {
  local_disk = true
}

data "databricks_spark_version" "latest_lts" {
  long_term_support = true
}

resource "databricks_cluster" "adf_cluster" {
  count = var.create_cluster ? 1 : 0

  cluster_name            = "ADF Cluster Terraform"
  spark_version           = data.databricks_spark_version.latest_lts.id
  node_type_id            = data.databricks_node_type.smallest.id
  runtime_engine          = "STANDARD"
  autotermination_minutes = 30

  autoscale {
    min_workers = 1
    max_workers = 6
  }
}
