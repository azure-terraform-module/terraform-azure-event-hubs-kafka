######################################
##              EVENTHUB            ##
######################################
variable "namespace" {
  description = "The name of the Event Hub."
  type        = string
}
 
variable "topics" {
  description = "The list of topics in the Event Hub Namespace."
  type        = list(object({
    name = string
    partition_count = optional(number)
    message_retention = optional(number) 
  }))
  default     = []
}
 
variable "capacity" {
  description = "Numbet of PUs for the Event Hub Namespace."
  type        = number
  default     = 1
}

variable "network_mode" {
  description = "Network mode for Event Hubs: private, service, or public."
  type        = string
  default     = "public"
  validation {
    condition     = !(var.sku == "Basic" && contains(["private", "service"], var.network_mode))
    error_message = "Network modes 'private' and 'service' are not supported for Basic SKU. Use Standard or Premium."
  }
  validation {
    condition     = contains(["public", "private", "service"], var.network_mode)
    error_message = "network_mode must be one of: public, private, service."
  }
}
 
variable "sku" {
  description = "The SKU of the Event Hub Namespace."
  type        = string
  default     = "Premium"
}
 
######################################
##              NETWORK             ##
######################################
variable "private_dns_zone_ids" {
  description = "The resource ID of the private DNS zone for Event Hub."
  type        = list(string)
  default     = []
}
 
variable "subnet_ids" {
  description = "The resource ID of the subnet for the private endpoint."
  type        = list(string)
  default     = []
}
 
variable "vnet_ids" {
  description = "List of VNet IDs used for linking to Private DNS Zone - Only for private endpoints."
  type        = list(string)
  default     = []
}
