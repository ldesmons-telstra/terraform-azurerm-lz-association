/* ----------------------------------------------------------------
   Create the vnet peering from the source vnet to the target vnet.
   ----------------------------------------------------------------
*/

resource "azurerm_virtual_network_peering" "peering" {
  name                      = "${var.vnet_name}-to-${var.remote_vnet_name}-peering"
  resource_group_name       = var.resource_group_name
  virtual_network_name      = var.vnet_name
  remote_virtual_network_id = var.remote_vnet_id
  allow_forwarded_traffic   = true
  allow_gateway_transit     = var.vnet_is_hub ? true : false
  use_remote_gateways       = var.vnet_is_hub ? false : true
}
