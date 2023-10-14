locals {
  admin_username = "adminev"
  kv1_name = "${var.resource_type.key_vault}-${var.azure_location_short}-evtest-01"
  rg1_name = "${var.resource_type.resource_group}-${var.azure_location_short}"
  web_subnet_name = "${var.resource_type.subnet}-${var.subnet.web}"
  data_subnet_name = "${var.resource_type.subnet}-${var.subnet.data}"
  jump_subnet_name = "${var.resource_type.subnet}-${var.subnet.jumpbox}"
  vnet1_name = "${var.resource_type.virtual_network}-${var.azure_location_short}"
  nsg_name = "${var.resource_type.network_security_group}-${var.subnet.web}-${var.azure_location_short}"
  pip1_name = "${var.resource_type.public_ip}-${var.azure_location_short}-01"
  nic1_name = "${var.resource_type.network_interface}-${var.azure_location_short}-01"
  nic2_name = "${var.resource_type.network_interface}-${var.azure_location_short}-02"
  web_vm_name = "${var.resource_type.virtual_machine}-${var.subnet.web}-${var.azure_location_short}-01"
  jump_vm_name = "${var.resource_type.virtual_machine}-${var.subnet.jumpbox}-${var.azure_location_short}-01"
  rsv_name = "${var.resource_type.recovery_service_vault}-${var.azure_location_short}"
  backup_policy_name = "${var.resource_type.backup_policy}-${var.azure_location_short}-01"
}

