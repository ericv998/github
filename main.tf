resource "azurerm_resource_group" "rg1" {
  name     = "${var.resource_type.resource_group}-${var.azure_location_short}"
  location = var.azure_location
  tags     = var.tags
}

resource "azurerm_subnet" "Web" {
  name                 = "${var.resource_type.subnet}-${var.subnet.web}"
  address_prefixes     = var.web_subnet_address_space
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
}

resource "azurerm_subnet" "Data" {
  name                 = "${var.resource_type.subnet}-${var.subnet.data}"
  address_prefixes     = var.data_subnet_address_space
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
}

resource "azurerm_subnet" "Jumpbox" {
  name                 = "${var.resource_type.subnet}-${var.subnet.jumpbox}"
  address_prefixes     = var.jumpbox_subnet_address_space
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
}

resource "azurerm_network_interface_security_group_association" "nsgassoc1" {
  network_interface_id      = azurerm_network_interface.nic1.id
  network_security_group_id = azurerm_network_security_group.nsg1.id
}

resource "azurerm_virtual_network" "vnet1" {
  name                = "${var.resource_type.virtual_network}-${var.azure_location_short}"
  resource_group_name = azurerm_resource_group.rg1.name
  address_space       = var.vnet1_address_space
  location            = var.azure_location
  tags                = var.tags
}

resource "azurerm_network_security_group" "nsg1" {
  name                = "${var.resource_type.network_security_group}-${var.subnet.web}-${var.azure_location_short}"
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.rg1.name
  tags                = var.tags
}

resource "azurerm_public_ip" "pip1" {
  name                = "${var.resource_type.public_ip}-${var.azure_location_short}-01"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = var.azure_location
  allocation_method   = var.ip_allocation.static
  tags                = var.tags
}

resource "azurerm_network_interface" "nic1" {
  name                = "${var.resource_type.network_interface}-${var.azure_location_short}-01"
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.rg1.name
  tags                = var.tags

  ip_configuration {
    name                          = "public-nic"
    private_ip_address_allocation = var.ip_allocation.dynamic
    subnet_id                     = azurerm_subnet.Web.id
    public_ip_address_id          = azurerm_public_ip.pip1.id
  }
}

resource "azurerm_network_interface" "nic2" {
  name                = "${var.resource_type.network_interface}-${var.azure_location_short}-02"
  location            = var.azure_location
  resource_group_name = azurerm_resource_group.rg1.name
  tags                = var.tags

  ip_configuration {
    name                          = "private-nic"
    subnet_id                     = azurerm_subnet.Jumpbox.id
    private_ip_address_allocation = var.ip_allocation.dynamic
  }
}

resource "azurerm_linux_virtual_machine" "vm-Web-EUS2-001" {
  resource_group_name             = azurerm_resource_group.rg1.name
  admin_username                  = local.admin_username
  admin_password                  = local.admin_password
  location                        = var.azure_location
  name                            = "${var.resource_type.virtual_machine}-${var.subnet.web}-${var.azure_location_short}-01"
  network_interface_ids           = [azurerm_network_interface.nic1.id]
  size                            = var.vm_size.stan_b1ms
  disable_password_authentication = var.disable_pass_auth
  tags                            = var.tags
  os_disk {
    caching              = var.os_disk.caching
    storage_account_type = var.os_disk.storage_account_type
  }
  source_image_reference {
    publisher = var.ubuntu22.publisher
    offer     = var.ubuntu22.offer
    sku       = var.ubuntu22.sku
    version   = var.ubuntu22.version
  }
}

resource "azurerm_windows_virtual_machine" "vm-jump-eus2-01" {
  resource_group_name   = azurerm_resource_group.rg1.name
  admin_username        = local.admin_username
  admin_password        = local.admin_password
  location              = var.azure_location
  name                  = "${var.resource_type.virtual_machine}-${var.subnet.jumpbox}-${var.azure_location_short}-01"
  network_interface_ids = [azurerm_network_interface.nic2.id]
  size                  = var.vm_size.stan_b1ms
  tags                  = var.tags
  os_disk {
    caching              = var.os_disk.caching
    storage_account_type = var.os_disk.storage_account_type
  }
  source_image_reference {
    publisher = var.Windows2019DC.publisher
    offer     = var.Windows2019DC.offer
    sku       = var.Windows2019DC.sku
    version   = var.Windows2019DC.version
  }
}

resource "azurerm_recovery_services_vault" "rsv001" {
  name                = "${var.resource_type.recovery_service_vault}-${var.azure_location_short}"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = var.azure_location
  sku                 = var.rsv_sku
  tags                = var.tags
}

resource "azurerm_backup_policy_vm" "backuppolicy1" {
  name                = "${var.resource_type.backup_policy}-${var.azure_location_short}-01"
  resource_group_name = azurerm_resource_group.rg1.name
  recovery_vault_name = azurerm_recovery_services_vault.rsv001.name
  backup {
    frequency = var.backup_pol_freq
    time      = var.backup_time
  }
  retention_daily {
    count = var.backups_to_keep
  }
}

resource "azurerm_backup_protected_vm" "vm-Web-EUS2-001_bu" {
  resource_group_name = azurerm_resource_group.rg1.name
  recovery_vault_name = azurerm_recovery_services_vault.rsv001.name
  source_vm_id        = azurerm_linux_virtual_machine.vm-Web-EUS2-001.id
  backup_policy_id    = azurerm_backup_policy_vm.backuppolicy1.id
}

resource "azurerm_backup_protected_vm" "vm-jump-eus2-01_bu" {
  resource_group_name = azurerm_resource_group.rg1.name
  recovery_vault_name = azurerm_recovery_services_vault.rsv001.name
  source_vm_id        = azurerm_windows_virtual_machine.vm-jump-eus2-01.id
  backup_policy_id    = azurerm_backup_policy_vm.backuppolicy1.id
}