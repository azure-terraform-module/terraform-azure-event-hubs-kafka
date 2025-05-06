locals {
  # Get subnet names from subnet IDs
  subnet_info = {
    for subnet_id in var.subnet_ids : subnet_id => {
      name = try(regex("subnets/([^/]+)$", subnet_id)[0], "subnet-${md5(subnet_id)}")
    }
  }

    # Endpoint types
  is_private = var.eventhub_network_mode == "private" # Private endpoint - Traffic in VNet 
  is_service = var.eventhub_network_mode == "service" # Service endpoint - Traffic in Azure backbone 
  is_public  = var.eventhub_network_mode == "public"  # Public endpoint  - Traffic over the internet

  # Public network access - Service endpoints, Public endpoints
  public_network_access = local.is_service || local.is_public ? true : false


  # Create private DNS zone if not provided - Private endpoint
  private_dns_zone_ids = local.is_private ? (
    var.eventhub_private_dns_zone_id != [] ? var.eventhub_private_dns_zone_id : (
      length(azurerm_private_dns_zone.private_dns_eventhub) > 0 ? [azurerm_private_dns_zone.private_dns_eventhub[0].id] : []
    )
  ) : []

  # Network rulesets - Service endpoints
  network_rulesets = [
    {
      default_action                 = local.is_public ? "Allow" : "Deny" # If use public endpoint, must allow all traffic
      trusted_service_access_enabled = true
      public_network_access_enabled  = local.public_network_access # Service endpoints, Public endpoints

      # Vnet rules - Service endpoints
      virtual_network_rule = local.is_service ? [
        for subnet_id in var.subnet_ids : {
          subnet_id                                       = subnet_id
          ignore_missing_virtual_network_service_endpoint = true
        }
      ] : []

      # IP rules - Service endpoints
      ip_rule = local.is_service ? [
        for ip in var.ip_rules : {
          ip_mask = ip
          action  = "Allow"
      }] : []
    }
  ]

}
