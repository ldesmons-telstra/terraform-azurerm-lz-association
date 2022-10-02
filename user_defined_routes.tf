/* -----------------------
   Locals.
   -----------------------
*/

locals {
  route_table_hub_count   = var.vnet_is_hub && var.firewall_private_ip_address != "" ? 1 : 0
  route_table_spoke_count = !var.vnet_is_hub && var.firewall_private_ip_address != "" ? 1 : 0
}

# route table from hub gateway -> spoke subnets (via firewall)
resource "azurerm_route_table" "route_table_hub" {
  count                         = local.route_table_hub_count
  name                          = var.route_table_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = false

  # one route to every spoke subnets
  dynamic "route" {
    for_each = { for index, subnet in var.spoke_subnets_address_prefixes : subnet => index }
    content {
      name                   = "route-gateway-subnet-${index}"
      address_prefix         = each.value
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = var.firewall_private_ip_address
    }
  }

  tags = var.tags
}

# association route table hub for the gateway subnet
resource "azurerm_subnet_route_table_association" "route_table_hub_association" {
  count          = local.route_table_hub_count
  subnet_id      = var.gateway_subnet_id
  route_table_id = azurerm_route_table.route_table_hub[0].id
}

# route table from spoke subnets -> local network gateway adress space (via firewall)
resource "azurerm_route_table" "route_table_spoke" {
  count                         = local.route_table_spoke_count
  name                          = var.route_table_name
  location                      = var.location
  resource_group_name           = var.resource_group_name
  disable_bgp_route_propagation = false

  # one route for every adress space in the local network gatewy
  dynamic "route" {
    for_each = { for index, address in var.hub_local_network_gateway_address_space : address => index }
    content {
      name                   = "route-subnet-gateway-${index}"
      address_prefix         = each.value
      next_hop_type          = "VirtualAppliance"
      next_hop_in_ip_address = var.firewall_private_ip_address
    }
  }

  tags = var.tags
}

# association route table spoke for every spoke subnet
resource "azurerm_subnet_route_table_association" "route_table_spoke_association" {
  for_each       = var.spoke_subnets_ids
  subnet_id      = each.value
  route_table_id = azurerm_route_table.route_table_spoke[0].id
}