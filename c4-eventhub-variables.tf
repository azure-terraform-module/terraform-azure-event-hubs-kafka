######################################
##              EVENTHUB            ##
######################################
variable "eventhub_namespace" {
  description = "The name of the Event Hub."
  type        = string
}

variable "topics" {
  description = "The list of topics in the Event Hub Namespace."
  type        = list(string)
  default     = []
}
 
variable "capacity" {
  description = "Numbet of PUs for the Event Hub Namespace."
  type        = number
  default     = 1
}
 
variable "partition_count" {
  description = "The number of partitions for the Event Hub (topics)."
  type        = number
  default     = 1
}
 
variable "eventhub_network_mode" {
  description = "Network mode for Event Hub: private, service, public."
  type        = string
}
 
######################################
##              NETWORK             ##
######################################
variable "eventhub_private_dns_zone_ids" {
  description = "The resource ID of the private DNS zone for Event Hub."
  type        = list(string)
  default     = []
}
 
variable "subnet_ids" {
  description = "The resource ID of the subnet for the private endpoint."
  type        = list(string)
  default     = []
}
 
variable "ip_rules" {
  description = "CIDR blocks to allow access to the Event Hub - Only for service endpoints."
  type        = list(string)
  default     = []
}
 
variable "vnet_ids" {
  description = "List of VNet IDs used for linking to Private DNS Zone - Only for private endpoints."
  type        = list(string)
  default = []
}
 
 
