# terraform-azure-event-hubs-kafka

This module deploys an Azure Event Hubs namespace with Kafka enabled. It is designed to be used with Terraform and provides a simple way to set up an Event Hubs namespace with Kafka support.

Currently, the module only supports for Premium SKU. 

# Key Features 

variables.tf file 
```
######################################
##              COMMON              ##
######################################
variable "resource_group_name" {
  description = "The name of the resource group where the resources will be created."
  type        = string
  default     = "minh-test"
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
}
```
