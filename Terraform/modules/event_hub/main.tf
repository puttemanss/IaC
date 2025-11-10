resource "azurerm_eventhub_namespace" "event_hub_namespace" {
  name                = var.namespace_name
  location            = var.location
  resource_group_name = var.resource_group_name
  sku                 = var.sku

  local_authentication_enabled = false

  capacity                 = var.sku == "Standard" ? var.capacity : null
  auto_inflate_enabled     = var.sku == "Standard" ? var.auto_inflate_enabled : null
  maximum_throughput_units = var.auto_inflate_enabled ? var.maximum_throughput_units : 0

  public_network_access_enabled = !var.include_networking

  identity {
    type         = "UserAssigned"
    identity_ids = var.user_assigned_identity_ids
  }
  tags = var.tags
}

resource "azurerm_eventhub" "event_hub" {
  name              = var.event_hub_name
  namespace_id      = azurerm_eventhub_namespace.event_hub_namespace.id
  partition_count   = var.partition_count
  message_retention = var.message_retention

  dynamic "capture_description" {
    for_each = var.enable_data_capture ? [1] : []
    content {
      enabled             = var.enable_data_capture
      encoding            = "Avro"
      interval_in_seconds = var.capture_interval

      destination {
        name                = "EventHubArchive.AzureBlockBlob"
        archive_name_format = "eventhub/{Namespace}/{EventHub}/{PartitionId}/{Year}/{Month}/{Day}/{Hour}/{Minute}/{Second}"
        storage_account_id  = var.capture_storage_account_id
        blob_container_name = var.capture_blob_container_name
      }
    }
  }
}

module "pep_event_hub_namespace" {
  count = var.include_networking ? 1 : 0

  source                = "../private_endpoint"
  name                  = "pep-event-hub-namespace-${var.environment}"
  location              = var.location
  resource_group_name   = var.networking_resource_group_name
  subnet_id             = var.data_platform_subnet_id
  private_ip_address    = var.pep_namespace_ip
  resource_id           = azurerm_eventhub_namespace.event_hub_namespace.id
  resource_name         = azurerm_eventhub_namespace.event_hub_namespace.name
  subresource_name      = "namespace"
  member_name           = "namespace"
  private_dns_zone_name = "privatelink.servicebus.windows.net"
  virtual_network_id    = var.vnet_id
  tags                  = var.tags
}
