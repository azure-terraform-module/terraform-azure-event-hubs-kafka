# terraform-azure-event-hubs-kafka

This module deploys an Azure Event Hubs namespace with Kafka enabled. It is designed to be used with Terraform and provides a simple way to set up an Event Hubs namespace with Kafka support.

Currently, the module only supports for Premium SKU. 

# Key Features 

- Supports private, service, and public network modes with automatic configuration.
- Auto-creation of Private Endpoints and optional Private DNS Zones for seamless VNet integration.
- Dynamic network rulesets (VNet and IP-based) generated based on selected network mode.
- DNS zone linking for multiple VNets if needed.

variables.tf file 
```
######################################
##              GENERIC             ##
######################################
variable "resource_group_name" {
  description = "The name of the resource group where the resources will be created."
  type        = string
  default     = "rg-eventhub-terraform"
}

variable "location" {
  description = "The Azure location where the resources will be created."
  type        = string
  default = "eastus"
}

variable "tags" {
  description = "Tags to assign to the resource."
  type        = map(string)
  default     = {
    createBy = "Terraform"
  }
}

######################################
##              EVENTHUB            ##
######################################
variable "eventhub_name" {
  description = "The name of the Event Hub."
  type        = string
  default     = "eventhub-terraform"
}

variable "capacity" {
  description = "Numbet of PUs for the Event Hub Namespace."
  type        = number
  default     = 1
}

variable "partition_count" {
  description = "The number of partitions for the Event Hub."
  type        = number
  default     = 1
}

variable "eventhub_network_mode" {
  description = "Network mode for Event Hub: private, service, public."
  type        = string
  default     = "private"
}

######################################
##              NETWORK             ##
######################################
variable "eventhub_private_dns_zone_id" {
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
  default     = []
}
``` 

provider.tf 
``` 
terraform {
  required_version = ">= 1.9, < 2.0"
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "4.25.0"
    }
  }
  backend "azurerm" {
    resource_group_name  = "<your-resource-group-name>"
    storage_account_name = "<your-storage-account-name>"
    container_name       = "<your-container-name>"
    key                  = "<your-key>"
    subscription_id = "<your-subscription-id>"
    }
}

provider "azurerm" {
  features {
  }
  subscription_id = "<your-subscription-id>"
}
``` 

output.tf 
```
output "namespace_name" {
  description = "The name of the Event Hub Namespace"
  value       = module.eventhub.namespace_name
}

output "namespace_id" {
  description = "The ID of the Event Hub Namespace"
  value       = module.eventhub.namespace_id
}  

output "name" {
  description = "The name of the Event Hub"
  value       = module.eventhub.name
}

output "id" {
  description = "The ID of the Event Hub"
  value       = module.eventhub.id
}

output "hostname" {
  description = "The hostname of the Event Hub Namespace"
  value       = module.eventhub.hostname
}
``` 

main.tf 
```
data "terraform_remote_state" "vnet" {
  backend = "azurerm"

  config = {
    resource_group_name  = "<your-resource-group-name>"
    storage_account_name = "<your-storage-account-name>"
    container_name       = "<your-container-name>"
    key                  = "<your-key>"
    subscription_id      = "<your-subscription-id>"
  }
}

module "eventhub" {
  source = "../terraform-azure-event-hubs-kafka"

  resource_group_name = var.resource_group_name
  location           = var.location
  eventhub_name      = var.eventhub_name 

  tags = var.tags 
  eventhub_network_mode = "private" # private, service, public

  subnet_ids = data.terraform_remote_state.vnet.outputs.subnet_ids 
  vnet_ids = [data.terraform_remote_state.vnet.outputs.vnet_id]

  capacity = 1 
  partition_count = 2
}
```
