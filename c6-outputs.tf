output "namespace_id" {
  description = "The ID of the Event Hubs namespace"
  value       = azurerm_eventhub_namespace.eventhub_namespace.id
}

output "namespace" {
  description = "The name of the Event Hubs namespace"
  value       = azurerm_eventhub_namespace.eventhub_namespace.name
}

output "hostname" {
  description = "The hostname of the Event Hubs namespace"
  value       = "${azurerm_eventhub_namespace.eventhub_namespace.name}.servicebus.windows.net"
}

output "eventhub_names" {
  description = "Names of Event Hubs created in the namespace"
  value       = keys(azurerm_eventhub.eventhub_topic)
}

output "eventhubs" {
  description = "Map of Event Hub name to Event Hub ID"
  value       = { for name, eh in azurerm_eventhub.eventhub_topic : name => eh.id }
}

output "private_endpoint_ids" {
  description = "IDs of private endpoints created for the Event Hubs namespace (empty if not using private mode)"
  value       = [for pe in azurerm_private_endpoint.eventhub_private_endpoint : pe.id]
}

output "private_dns_zone_ids" {
  description = "Private DNS zone IDs associated with the namespace (created or provided)"
  value       = local.private_dns_zone_ids
}

output "vnet_link_ids" {
  description = "IDs of VNet links to the private DNS zone (empty if not using private mode)"
  value       = [for l in azurerm_private_dns_zone_virtual_network_link.eventhub_private_dns_zone_link : l.id]
}
