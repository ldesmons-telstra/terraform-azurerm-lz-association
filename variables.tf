/* -----------------------
   General variables (required).
   -----------------------
*/

variable "resource_group_name" {
  type        = string
  description = "The name of the existing resource group."
}

variable "location" {
  type        = string
  description = "Location where the resources are going to be created."
}

/* -----------------------
   Vnet variables (required).
   -----------------------
*/

variable "vnet_name" {
  type        = string
  description = "The name of the vnet."
}

variable "vnet_is_hub" {
  type        = bool
  default     = false
  description = "True is the vnet is the hub, False if it is a spoke."
}

variable "remote_vnet_id" {
  type        = string
  description = "The id of the remote vnet."
}

/* ----------------------
   spoke subnets variables
   ----------------------
*/

variable "spoke_subnets_ids" {
  type        = map(string)
  default     = null
  description = "(Optional) The ids of the subnets (mandatory for a spoke vnet)."
}

variable "spoke_subnets_address_prefixes" {
  type        = list(string)
  default     = []
  description = "(Optional) The address prefixes of the subnets (for a spoke vnet)."
}


/* -----------------------
   vnet gateway variables.
   -----------------------
*/
variable "gateway_subnet_id" {
  type        = string
  description = "The subnet id of the gateway (in the hub vnet)."
}

/* -----------------------
   Firewall variables (optional).
   -----------------------
*/

variable "firewall_name" {
  type        = string
  default     = ""
  description = "(Optional) The name of the firewall rules (for the hub vnet)."
}

variable "firewall_rules_collection_name" {
  type        = string
  default     = "firewall-rules"
  description = "(Optional) The name of the firewall rules collection (for the hub vnet)."
}

variable "firewall_rules_collection_priority" {
  type        = number
  default     = 500
  description = "(Optional) The priority of the firewall rules collection (for the hub vnet)."
}

variable "firewall_private_ip_address" {
  type        = string
  default     = ""
  description = "(Optional) The private ip of the firewall (for the hub vnet)."
}

variable "hub_local_network_gateway_address_space" {
  type        = list(string)
  default     = []
  description = "(Optional) The address space of the local network gateway (in the hub vnet)."
}

/* -----------------------
   Route tables variables (optional).
   -----------------------
*/
variable "route_table_name" {
  type        = string
  default     = ""
  description = "(Optional) The name of the route table."
}

/* -----------------------
   Tags (optional).
   -----------------------
*/

variable "tags" {
  type        = map(string)
  default     = {}
  description = "(Optional) The tags to apply to all resources."
}