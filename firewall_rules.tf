/* -----------------------
   Locals.
   -----------------------
*/

locals {
  firewall_count = var.vnet_is_hub && var.firewall_name != "" ? 1 : 0
}

/* ----------------------------------------------------------------
   Create the firewall rules (in the hub vnet) to allow trafic between the hub gateway and the spoke subnets (optional).
   ----------------------------------------------------------------
*/

resource "azurerm_firewall_network_rule_collection" "firewall_rules_collection" {
  count               = local.firewall_count
  name                = var.firewall_rules_collection_name
  azure_firewall_name = var.firewall_name
  resource_group_name = var.resource_group_name
  priority            = var.firewall_rules_collection_priority
  action              = "Allow"

  # rule hub -> spokes
  rule {
    name                  = var.firewall_rules_local_network_to_spokes_name
    source_addresses      = var.hub_local_network_gateway_address_space
    destination_ports     = ["*"]
    destination_addresses = var.spoke_subnets_address_prefixes
    protocols             = ["Any"]
  }

  # rule spokes-> hub
  rule {
    name                  = var.firewall_rules_spokes_to_local_network_name
    source_addresses      = var.spoke_subnets_address_prefixes
    destination_ports     = ["*"]
    destination_addresses = var.hub_local_network_gateway_address_space
    protocols             = ["Any"]
  }
}


