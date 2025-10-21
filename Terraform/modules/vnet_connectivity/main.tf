/*
Goal of this module:
Based on the flags 'vpn_connection' and 'vm_connection' create a Virtual Network Gateway or a Virtual Machine in the default subnet for access to the solution.
*/

/*
VPN connection
*/
module "vpn_connection" {
  count                                      = var.include_vpn_connection ? 1 : 0
  source                                     = "../virtual_network_gateway"
  resource_group_name                        = var.networking_resource_group_name
  location                                   = var.location
  tenant_id                                  = var.vpn_tenant_id
  name                                       = "vgw-${var.project_name}-${var.environment}"
  vnet_name                                  = var.vpn_vnet_name
  GatewaySubnet_cidr_block                   = var.vpn_GatewaySubnet_cidr_block
  vpn_configuration_address_space_cidr_block = var.vpn_configuration_address_space_cidr_block
  vpn_application_id                         = var.vpn_application_id
  tags                                       = var.tags
}

/*
VM connection
*/
module "vm_connection" {
  count                          = var.include_vm_connection ? 1 : 0
  source                         = "../windows_virtual_machine"
  name                           = "vm-${var.project_name}-${var.environment}"
  resource_group_name            = var.vm_resource_group_name
  location                       = var.location
  admin_username                 = var.vm_admin_username
  admin_password                 = var.vm_admin_password
  size                           = var.vm_size
  subnet_id                      = var.vm_nic_subnet_id
  ip_address                     = var.vm_nic_ip_address
  networking_resource_group_name = var.networking_resource_group_name
  source_image_reference         = var.vm_source_image_reference
  tags                           = var.tags
}
