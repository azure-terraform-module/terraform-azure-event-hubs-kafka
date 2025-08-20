# terraform-azurerm-eventhub
this terraform module provisions an **azure event hub** namespace and its associated resources with support for **private**, **service**, and **public** network modes.
## 1. features
- support for **private**, **service**, and **public** access modes.
- automatic provisioning of **private dns zones** and **virtual network links** if not provided.
- configurable **vnet rules** for service endpoint mode (applies when `sku = "Premium"`).
- supports tagging, resource grouping, and subnet customization.
## 2. module usage
### 2.1. prerequisites
ensure that you have the following:
- terraform `>= 1.3`
- azurerm provider `~> 4.25.0`
- proper permissions in your azure subscription to create event hub, dns zones, vnets, and private endpoints.
### 2.2. `network_mode`
specify how the event hub should be exposed:
- `private`: uses private endpoint and private dns zones (no public access).
 
  ![alt text](https://raw.githubusercontent.com/azure-terraform-module/terraform-azure-event-hubs-kafka/refs/heads/master/images/1.png)
- `service`: uses service endpoints and ip/vnet rules.
 
	![alt text](https://raw.githubusercontent.com/azure-terraform-module/terraform-azure-event-hubs-kafka/refs/heads/master/images/2.png)
- `public`: open to public internet access
 
	![alt text](https://raw.githubusercontent.com/azure-terraform-module/terraform-azure-event-hubs-kafka/refs/heads/master/images/3.png)
### 2.3. input variables
 
| name                   | type           | required | default                | description                                                                 |
| ---------------------- | -------------- | -------- | ---------------------- | --------------------------------------------------------------------------- |
| `namespace`            | `string`       | ✅        | —                      | the name of the event hub namespace.                                        |
| `topics`               | `list(object({ name = string, partition_count = optional(number), message_retention = optional(number) }))` | ❌ | `[]` | event hubs to create. per-hub overrides (defaults: 2 partitions, 7 days). |
| `capacity`             | `number`       | ❌        | `1`                    | number of pus for the event hub namespace.                                  |
| `network_mode`         | `string`       | ✅        | —                      | network mode for event hub: `private`, `service`, `public`.                 |
| `private_dns_zone_ids` | `list(string)` | ❌        | `[]`                   | the resource id of the private dns zone for event hub.                      |
| `subnet_ids`           | `list(string)` | ❌        | `[]`                   | the resource id of the subnet.                                             |
| `vnet_ids`             | `list(string)` | ❌        | `[]`                   | vnet ids used for linking to private dns zone (only for private endpoints). |
| `resource_group_name`  | `string`       | ❌        | `"terraform-eventhub"` | the name of the resource group where the resources will be created.         |
| `location`             | `string`       | ✅        | —                      | the azure location where the resources will be created.                     |
| `tags`                 | `map(string)`  | ❌        | `{}`                   | tags to assign to the resources.                                            |
| `sku`                  | `string`       | ❌        | `"Premium"`           | the sku of the event hub namespace.                                         |
 
### 2.4 example
### variable require by `network mode`
| `network_mode`       | `private_dns_zone_ids` | `subnet_ids` | `vnet_ids` |
| -------------------- | ---------------------- | ------------ | ---------- |
| **private endpoint** | 🟦                     | ✅ (at least 1) | ✅         |
| **service endpoint** | ❌                     | ✅           | ❌         |
| **public endpoint**  | ❌                     | ❌           | ❌         |
 
##### notes:
- ✅ = **required** 
- ❌ = **not required**
- 🟦 = **optional**
 
#### main.tf 
network mode - private
- when using private mode, `subnet_ids` is where the private endpoint ip will be created. you need at least one subnet id. if `private_dns_zone_ids` are not provided, a private dns zone and vnet links will be created and associated.
```hcl
module "eventhub" {
  source  = "azure-terraform-module/event-hubs-kafka/azure"
  version = "0.0.3"
 
  # required variables
  namespace            = "my-eventhub-private-mode" # must be unique name
  resource_group_name  = "my-rg"
  location             = "eastus"
  network_mode         = "private"
  subnet_ids = [
    "/subscriptions/xxx/resourcegroups/my-rg/providers/microsoft.network/virtualnetworks/my-vnet/subnets/subnet1"
  ]
  vnet_ids = [
	"/subscriptions/xxx/resourcegroups/my rg/providers/microsoft.network/virtualnetworks/my-vnet"
  ]
 
  # optional variables
  private_dns_zone_ids = [
    "/subscriptions/xxx/resourcegroups/my-rg/providers/microsoft.network/privatednszones/my-private-dns-zone"
  ]
  tags = {
    environment = "dev"
    project     = "eventhub-provisioning"
  }
  topics = [
    { name = "topic1", partition_count = 4, message_retention = 7 },
    { name = "topic2" } # defaults: 2 partitions, 7 days
  ]
}
```
 
network mode - service
- when using service mode, `subnet_ids` define which subnets can access the namespace via service endpoints. network rules are applied when `sku = "Premium"`.
```hcl
module "eventhub" {
  source  = "azure-terraform-module/event-hubs-kafka/azure"
  version = "0.0.3"
 
  # required variables
  namespace            = "my-eventhub-service-mode" 
  resource_group_name  = "my-rg"
  location             = "eastus"
  network_mode         = "service"
  sku                  = "Premium"
  subnet_ids = [
    "/subscriptions/xxx/resourcegroups/my-rg/providers/microsoft.network/virtualnetworks/my-vnet/subnets/subnet1"
  ]
  tags = {
    environment = "dev"
    project     = "eventhub-provisioning"
  }
  topics = [
    { name = "topic1" },
    { name = "topic2", partition_count = 8 }
  ]
}
```
 
network mode - public
```hcl
module "eventhub" {
  source  = "azure-terraform-module/event-hubs-kafka/azure"
  version = "0.0.3"
 
  namespace            = "my-eventhub-public-mode"
  resource_group_name  = "my-rg"
  location             = "eastus"
  network_mode         = "public"
  tags = {
    environment = "dev"
    project     = "eventhub-provisioning"
  }
  topics = [
    { name = "topic1" },
    { name = "topic2" }
  ]
}
```
 
#### provider.tf 
```hcl
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
 
#### outputs.tf 
```hcl
output "namespace" {
  description = "the name of the event hub namespace"
  value       = module.eventhub.namespace
}

output "namespace_id" {
  description = "the id of the event hub namespace"
  value       = module.eventhub.namespace_id
}

output "hostname" {
  description = "the hostname of the event hub namespace"
  value       = module.eventhub.hostname
}

output "eventhub_names" {
  description = "names of event hubs (topics) created"
  value       = module.eventhub.eventhub_names
}

output "eventhubs" {
  description = "map of event hub name to event hub id"
  value       = module.eventhub.eventhubs
}

output "private_endpoint_ids" {
  description = "ids of private endpoints created (empty if not using private mode)"
  value       = module.eventhub.private_endpoint_ids
}

output "private_dns_zone_ids" {
  description = "private dns zone ids associated (created or provided)"
  value       = module.eventhub.private_dns_zone_ids
}

output "vnet_link_ids" {
  description = "ids of vnet links to the private dns zone (empty if not using private mode)"
  value       = module.eventhub.vnet_link_ids
}
```
