# terraform-azurerm-eventhub
this terraform module provisions an **azure event hub** namespace and its associated resources with support for **private**, **service**, and **public** network modes.
## 1. features
- support for **private**, **service**, and **public** access modes.
- automatic provisioning of **private dns zones** and **virtual network links** if not provided.
- configurable **ip rules** and **vnet rules** for service endpoint mode.
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
| `namespace`            | `string`       | ✅        | —                      | the name of the event hub.                                                  |
| `topics`               | `list(string)` | ❌        | `[]`                   | the list of topics in the event hub namespace.                              |
| `capacity`             | `number`       | ❌        | `1`                    | number of pus for the event hub namespace.                                  |
| `partition_count`      | `number`       | ❌        | `1`                    | the number of partitions for each event hub (topic).                        |
| `network_mode`         | `string`       | ✅        | —                      | network mode for event hub: `private`, `service`, `public`.                 |
| `private_dns_zone_ids` | `list(string)` | ❌        | `[]`                   | the resource id of the private dns zone for event hub.                      |
| `subnet_ids`           | `list(string)` | ❌        | `[]`                   | the resource id of the subnet.                     |
| `ip_rules`             | `list(string)` | ❌        | `[]`                   | cidr blocks to allow access (only for service endpoints).                   |
| `vnet_ids`             | `list(string)` | ❌        | `[]`                   | vnet ids used for linking to private dns zone (only for private endpoints). |
| `resource_group_name`  | `string`       | ❌        | `"terraform-eventhub"` | the name of the resource group where the resources will be created.         |
| `location`             | `string`       | ✅        | —                      | the azure location where the resources will be created.                     |
| `tags`                 | `map(string)`  | ❌        | `{}`                   | tags to assign to the resources.                                            |
| `sku`                | `string`       | ❌        | `"Premium"`           | the sku of the event hub namespace.                                         |
 
### 2.4 example
### variable require by `network mode`
| `network_mode`       | `private_dns_zone_ids` | `subnet_ids` | `vnet_ids` | `ip_rules` |
| -------------------- | ---------------------- | ------------ | ---------- | ---------- |
| **private endpoint** | 🟦                     | ✅ (at least 1)          | ✅         | ❌         |
| **service endpoint** | ❌                     | ✅           | ❌         | 🟦         |
| **public endpoint**  | ❌                     | ❌           | ❌         | ❌         |
 
##### notes:
- ✅ = **required** 
- ❌ = **not required**
- 🟦 = **optional**
 
#### main.tf 
network mode - private
- when use private mode, variable `subnet_ids` is where the ip of private endpoint will be created. so you just need at least one subnet id, all the subnets in the vnet will be conect to event hub.
```hcl
module "eventhub" {
  source  = "azure-terraform-module/event-hubs-kafka/azure"
  version = "0.0.3"
 
  # required variables
  namespace         = "my-eventhub-private-mode" # must be unique name
  resource_group_name   = "my-rg"
  location              = "eastus"
  network_mode = "private"
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
    "topic1",
    "topic2"
  ]
}
```
 
network mode - service
- when use service mode, subnet_ids is what subnet can access the event hub. so you need to add the subnet id that you want to access the event hub.
```hcl
module "eventhub" {
  source  = "azure-terraform-module/event-hubs-kafka/azure"
  version = "0.0.3"
 
  # required variables
  namespace         = "my-eventhub-service-mode" 
  resource_group_name   = "my-rg"
  location              = "eastus"
  network_mode = "service"
  subnet_ids = [
    "/subscriptions/xxx/resourcegroups/my-rg/providers/microsoft.network/virtualnetworks/my-vnet/subnets/subnet1"
  ]
  # optional variables
  ip_rules = [
    "203.0.113.10"
  ]
  tags = {
    environment = "dev"
    project     = "eventhub-provisioning"
  }
  topics = [
    "topic1",
    "topic2"
  ]
}
```
 
network mode - public
```hcl
module "eventhub" {
  source  = "azure-terraform-module/event-hubs-kafka/azure"
  version = "0.0.3"
 
  namespace         = "my-eventhub-public-mode"
  resource_group_name   = "my-rg"
  location              = "eastus"
  network_mode = "public"
  tags = {
    environment = "dev"
    project     = "eventhub-provisioning"
  }
  topics = [
    "topic1",
    "topic2"
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
 
output "topics" {
  description = "list of event hub topics from the module"
  value       = module.eventhub.topics
}
 
output "hostname" {
  description = "the hostname of the event hub namespace"
  value       = module.eventhub.hostname
}
`
