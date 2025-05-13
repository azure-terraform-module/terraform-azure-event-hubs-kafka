output "namespace" {
  description = "The name of the Event Hub Namespace"
  value       = azurerm_eventhub_namespace.eventhub_namespace.name
}
 
output "namespace_id" {
  description = "The ID of the Event Hub Namespace"
  value       = azurerm_eventhub_namespace.eventhub_namespace.id
}

output "topics" {
  description = "The list of topics in the Event Hub Namespace"
  value       = [for eh in azurerm_eventhub.eventhub : eh.name]
}
 
output "hostname" {
  description = "The hostname of the Event Hub Namespace"
  value       = "${azurerm_eventhub_namespace.eventhub_namespace.name}.servicebus.windows.net"
}
