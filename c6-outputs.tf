output "namespace_name" {
  description = "The name of the Event Hub Namespace"
  value       = azurerm_eventhub_namespace.eventhub_namespace.name
}
 
output "namespace_id" {
  description = "The ID of the Event Hub Namespace"
  value       = azurerm_eventhub_namespace.eventhub_namespace.id
}
 
output "name" {
  description = "The name of the Event Hub"
  value       = azurerm_eventhub.eventhub.name
}
 
output "id" {
  description = "The ID of the Event Hub"
  value       = azurerm_eventhub.eventhub.id
}
 
output "hostname" {
  description = "The hostname of the Event Hub Namespace"
  value       = "${azurerm_eventhub_namespace.eventhub_namespace.name}.servicebus.windows.net"
}
