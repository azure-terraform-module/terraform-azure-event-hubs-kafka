# Create private DNS zone if not provided - Private endpoint 
resource "azurerm_private_dns_zone" "private_dns_eventhub" {
  count               = local.is_private && length(var.private_dns_zone_ids) == 0 ? 1 : 0
  name                = "privatelink.servicebus.windows.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}
 
# Create private DNS zone link - Private endpoint
resource "azurerm_private_dns_zone_virtual_network_link" "eventhub_private_dns_zone_link" {
  count = (
    local.is_private && length(var.private_dns_zone_ids) == 0
    ? length(var.vnet_ids)
    : 0
  )
 
  name                  = "${var.namespace}-dns-link-${basename(var.vnet_ids[count.index])}"
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_eventhub[0].name
  resource_group_name   = azurerm_private_dns_zone.private_dns_eventhub[0].resource_group_name
  virtual_network_id    = var.vnet_ids[count.index]
  tags                  = var.tags
 
  depends_on = [
    azurerm_private_dns_zone.private_dns_eventhub
  ]
}
 
# Create private endpoint - Private endpoint
resource "azurerm_private_endpoint" "eventhub_private_endpoint" {
  count = local.is_private ? length(var.subnet_ids) : 0
 
  name                = "${var.namespace}-private-endpoint-${local.subnet_info[var.subnet_ids[count.index]].name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = var.subnet_ids[count.index]
 
  private_service_connection {
    name                           = "${var.namespace}-private-connection-${local.subnet_info[var.subnet_ids[count.index]].name}"
    private_connection_resource_id = azurerm_eventhub_namespace.eventhub_namespace.id
    is_manual_connection           = false
    subresource_names              = ["namespace"]
  }
 
  dynamic "private_dns_zone_group" {
    for_each = length(local.private_dns_zone_ids) > 0 ? [1] : []
    content {
      name                 = "default"
      private_dns_zone_ids = local.private_dns_zone_ids
    }
  }
 
  tags = var.tags
 
  depends_on = [
    azurerm_private_dns_zone.private_dns_eventhub,
    azurerm_private_dns_zone_virtual_network_link.eventhub_private_dns_zone_link
  ]
}
 
# Event Hub Namespace
resource "azurerm_eventhub_namespace" "eventhub_namespace" {
  name                          = var.namespace
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = var.sku
  capacity                      = var.capacity
  tags                          = var.tags
  public_network_access_enabled = local.public_network_access
 
  dynamic "network_rulesets" {
    for_each = var.sku != "Basic" ? local.network_rulesets : []
     content {
      default_action                 = network_rulesets.value.default_action
      public_network_access_enabled  = network_rulesets.value.public_network_access_enabled
      virtual_network_rule = network_rulesets.value.virtual_network_rule
      trusted_service_access_enabled = network_rulesets.value.trusted_service_access_enabled
    }
  }
 
  identity {
    type = "SystemAssigned"
  }
}

# Event Hub Topic 
resource "azurerm_eventhub" "eventhub_topic" {
  for_each     = { for t in var.topics : t.name => t }
  name         = each.value.name
  namespace_id = azurerm_eventhub_namespace.eventhub_namespace.id
  partition_count          = lookup(each.value, "partition_count", 2)
  message_retention = lookup(each.value, "message_retention", 7)
}
