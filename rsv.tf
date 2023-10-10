resource "azurerm_recovery_services_vault" "rsv001" {
  name                = local.rsv_name
  resource_group_name = module.rg1.name
  location            = var.azure_location
  sku                 = var.rsv_sku
  tags                = var.tags
}

resource "azurerm_backup_policy_vm" "backuppolicy1" {
  name                = local.backup_policy_name
  resource_group_name = module.rg1.name
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
  resource_group_name = module.rg1.name
  recovery_vault_name = azurerm_recovery_services_vault.rsv001.name
  source_vm_id        = azurerm_linux_virtual_machine.vm-Web-EUS2-001.id
  backup_policy_id    = azurerm_backup_policy_vm.backuppolicy1.id
}

resource "azurerm_backup_protected_vm" "vm-jump-eus2-01_bu" {
  resource_group_name = module.rg1.name
  recovery_vault_name = azurerm_recovery_services_vault.rsv001.name
  source_vm_id        = azurerm_windows_virtual_machine.vm-jump-eus2-01.id
  backup_policy_id    = azurerm_backup_policy_vm.backuppolicy1.id
}