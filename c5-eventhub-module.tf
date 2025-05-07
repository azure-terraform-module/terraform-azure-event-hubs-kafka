# Create private DNS zone if not provided - Private endpoint 
resource "azurerm_private_dns_zone" "private_dns_eventhub" {
  count               = local.is_private && length(var.eventhub_private_dns_zone_id) == 0 ? 1 : 0
  name                = "privatelink.eventhubs.windows.net"
  resource_group_name = var.resource_group_name
  tags                = var.tags
}

# Create private DNS zone link - Private endpoint
resource "azurerm_private_dns_zone_virtual_network_link" "eventhub_private_dns_zone_link" {
  for_each = ( 
    local.is_private && length(var.eventhub_private_dns_zone_id) == 0 
      ? toset(var.vnet_ids) 
      : toset([])
  )
 
  name                  = "${var.eventhub_name}-dns-link-${basename(each.key)}"
  private_dns_zone_name = azurerm_private_dns_zone.private_dns_eventhub[0].name
  resource_group_name   = azurerm_private_dns_zone.private_dns_eventhub[0].resource_group_name
  virtual_network_id    = each.value
  tags                  = var.tags

  depends_on = [
    azurerm_private_dns_zone.private_dns_eventhub
  ]
}

# Create private endpoint - Private endpoint
resource "azurerm_private_endpoint" "eventhub_private_endpoint" {
  for_each            = (local.is_private 
    ? toset(var.subnet_ids) 
    : toset([])
  )
  name                = "${var.eventhub_name}-private-endpoint-${local.subnet_info[each.key].name}"
  location            = var.location
  resource_group_name = var.resource_group_name
  subnet_id           = each.key

  private_service_connection {
    name                           = "${var.eventhub_name}-private-connection-${local.subnet_info[each.key].name}"
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
}

# Event Hub Namespace
resource "azurerm_eventhub_namespace" "eventhub_namespace" {
  name                          = var.eventhub_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  sku                           = "Premium"
  capacity                      = var.capacity
  tags                          = var.tags
  public_network_access_enabled = local.public_network_access

  dynamic "network_rulesets" {
    for_each = local.network_rulesets
    content {
      default_action                 = network_rulesets.value.default_action
      trusted_service_access_enabled = network_rulesets.value.trusted_service_access_enabled
      public_network_access_enabled  = network_rulesets.value.public_network_access_enabled
      virtual_network_rule           = network_rulesets.value.virtual_network_rule
      ip_rule                        = network_rulesets.value.ip_rule
    }
  }

  identity {
    type = "SystemAssigned"
  }
}

# Event Hub
resource "azurerm_eventhub" "eventhub" {
  name              = var.eventhub_name
  namespace_id      = azurerm_eventhub_namespace.eventhub_namespace.id
  partition_count   = var.partition_count
  message_retention = 90
}


