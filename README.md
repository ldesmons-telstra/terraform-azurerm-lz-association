# Azure Landing Zone Hub-Spoke Association

This module associates a **hub vnet** and a **spoke vnet** in an Azure Landing Zone. The association is one-way only : to fully associate the hub and the spokes, one must associate the hub with the spokes, and then every spoke with the hub.

It is intented to be used in conjonction with the following modules :
 - **lz-hub module** which can be found here : https://registry.terraform.io/modules/ldesmons-telstra/lz-hub/azurerm/latest
 - **lz-spoke module** which can be found here : https://registry.terraform.io/modules/ldesmons-telstra/lz-spoke/azurerm/latest

![Telstra - Landing Zone (1)](https://user-images.githubusercontent.com/108506349/193437641-95b26822-e1c1-4df2-ab2c-740a511cb4bd.png)

## Features 

- creates a **vnet peering** from the source vnet (either hub or spoke) to the target vnet
- creates **firewall rules** (in the hub vnet) to allow traffic from the hub gateway to the spokes subnets (both ways)
- creates **user defined routes** to enforce the firewall in the hub vnet to the next-hop virtual appliance from the hub gateway or the spoke subnets

## Usage

**Create a hub vnet and a spoke vnet and associate them both ways**

```terraform

# resource groups
resource "azurerm_resource_group" "rg_hub" {
  name     = "my-rg-hub"
  location = "southeastasia"
  tags     = {
    "environment" : "dev"
  }
}

resource "azurerm_resource_group" "rg_spoke" {
  name     = "my-rg-spoke"
  location = "southeastasia"
  tags     = {
    "environment" : "dev"
  }
}

# hub vnet
module "vnet_hub" {
  source  = "ldesmons-telstra/lz-hub/azurerm"
  version = "1.0.2"

  location            = "southeastasia"
  resource_group_name = "my-rg-hub"
  name                = "my-vnet-hub"
  address_space       = ["10.10.31.0/24"]

  vnet_gateway_name                   = "my-vnet-gateway"
  vnet_gateway_address_prefixes       = ["10.10.31.128/27"]
  vnet_gateway_public_ip_name         = "my-vnet-gateway-pip"
  local_network_gateway_name          = "my-local-network-gateway"
  local_network_gateway_address       = "203.134.151.51"
  local_network_gateway_address_space = ["192.1.1.0/24", "192.168.0.0/24", "192.168.1.0/24", "192.2.2.0/24"]
  gateway_connection_name             = "my-local-network-gateway-connection"
  gateway_connection_shared_key       = "shared-key"

  firewall_name                       = "my-firewall"
  firewall_public_ip_name             = "my-firewall-pip"
  firewall_subnet_address_prefixes    = ["10.10.31.0/26"]

  bastion_name                        = "my-bastion"
  bastion_public_ip_name              = "my-bastion-pip"
  bastion_subnet_address_prefixes     = ["10.10.31.64/26"]

  tags = {
    "environment" : "dev"
  }
}

# spoke vnet (can add multiple spoke modules like this)
module "vnet_spoke" {
  source              = "ldesmons-telstra/lz-spoke/azurerm"
  version             = "1.0.2"

  location            = "southeastasia"
  resource_group_name = "my-rg-spoke"
  name                = "vnet-spoke"
  address_space       = ["10.0.0.0/24"]

  subnets = {
    subnet-01 = {
      name             = "subnet-01"
      address_prefixes = ["10.0.0.0/26"]
    }
    subnet-02 = {
      name             = "subnet-02"
      address_prefixes = ["10.0.0.1/26"]
    }
  }

  tags = {
    "environment" : "dev"
  }
}

# associate hub and spoke
module "hub_spoke_association" {
  source              = "ldesmons-telstra/lz-association/azurerm"
  version             = "1.0.2"

  resource_group_name = "my-rg-hub"
  location            = "southeastasia"

  # source vnet is hub
  vnet_name   = "my-vnet-hub"
  vnet_is_hub = true

  # firewall rules 
  firewall_name                           = "my-firewall"
  firewall_private_ip_address             = module.vnet_hub.firewall_private_ip_address
  hub_local_network_gateway_address_space = ["192.1.1.0/24", "192.168.0.0/24", "192.168.1.0/24", "192.2.2.0/24"]
  spoke_subnets_address_prefixes = ["10.0.0.0/26", "10.0.0.1/26"]

  # target vnet is the spoke
  remote_vnet_id = module.vnet_spoke.vnet_id

  # vnet gateway
  gateway_subnet_id = module.vnet_hub.gateway_subnet_id

  tags = {
    "environment" : "dev"
  }
}

# associate spoke and hub
module "spokes_hub_associations" {
  source              = "ldesmons-telstra/lz-association/azurerm"
  version             = "1.0.2"

  resource_group_name = "my-rg-spoke"
  location            = "southeastasia"

  # source vnet is the spoke
  vnet_name   = "vnet-spoke"
  vnet_is_hub = false

  # firewall rules 
  firewall_name                           = "my-firewall"
  firewall_private_ip_address             = module.vnet_hub.firewall_private_ip_address
  hub_local_network_gateway_address_space = ["192.1.1.0/24", "192.168.0.0/24", "192.168.1.0/24", "192.2.2.0/24"]
  spoke_subnets_address_prefixes = ["10.0.0.0/26", "10.0.0.1/26"]
  
  # target vnet is the hub
  remote_vnet_id = module.vnet_hub.vnet_id

  # vnet gateway
  gateway_subnet_id = module.vnet_hub.gateway_subnet_id

  # spoke subnet ids (mandatory for a spoke)
  spoke_subnets_ids = module.vnet_spoke.subnets_ids

  tags = {
    "environment" : "dev"
  }
}
```

