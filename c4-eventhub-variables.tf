######################################
##              EVENTHUB            ##
######################################
variable "eventhub_name" {
  description = "The name of the Event Hub."
  type        = string
}

variable "capacity" {
  description = "The capacity of the Event Hub namespace (1, 2, or 3)"
  type        = number
  default     = 1 
}

variable "partition_count" {
  description = "The number of partitions for the Event Hub."
  type        = number
  default     = 1
}

variable "eventhub_network_mode" {
  description = "Network mode for Event Hub: 'private' or 'service'"
  type        = string
  default     = "private"
  validation {
    condition     = contains(["private", "service", "public"], var.eventhub_network_mode)
    error_message = "eventhub_network_mode must be either 'private' or 'service' or 'public'"
  }
}

######################################
##              NETWORK             ##
######################################
variable "eventhub_private_dns_zone_id" {
  description = "The resource ID of the private DNS zone for Event Hub."
  type        = string
  default = ""
}

variable "subnet_ids" {
  description = "The resource ID of the subnet for the private endpoint."
  type        = list(string)
  default     = []
}

variable "ip_rules" {
  description = "The IP rules for the Event Hub namespace."
  type        = list(string)
  default     = []
}

variable "vnet_id" {
  description = "The resource ID of the virtual network."
  type        = string
}


