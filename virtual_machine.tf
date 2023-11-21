module "linux_virtual_machine" {
  count = var.linux_vm_count
  source = "./modules/linux_virtual_machine"
  name = "${local.web_vm_name}-0${count.index + 1}"
  location = var.azure_location
  resource_group = module.rg1.name
  vm_size = var.vm_size.stan_b1ms
  admin_password = azurerm_key_vault_secret.admin_pw_lin.value
  nic_id = azurerm_network_interface.linux_nics[count.index].id
  disable_pass_auth = var.disable_pass_auth
  tags = var.tags
  os_disk = var.os_disk
  ubuntu22 = var.ubuntu22
  avail_set = azurerm_availability_set.linux_availability_set.id
}

resource "azurerm_windows_virtual_machine" "vm-jump-eus2-01" {
  resource_group_name   = module.rg1.name
  admin_username        = local.admin_username
  admin_password        = azurerm_key_vault_secret.admin_pw_win.value
  location              = var.azure_location
  name                  = local.jump_vm_name
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

resource "azurerm_network_interface" "linux_nics" {
  count = var.linux_vm_count
  name                = "${local.linux_nic_name}-0${count.index + 1}"
  location            = var.azure_location
  resource_group_name = module.rg1.name
  tags                = var.tags

  ip_configuration {
    name                          = "private-nic"
    private_ip_address_allocation = var.ip_allocation.dynamic
    subnet_id                     = azurerm_subnet.Web.id
  }
}

resource "azurerm_network_interface" "nic2" {
  name                = local.nic2_name
  location            = var.azure_location
  resource_group_name = module.rg1.name
  tags                = var.tags

  ip_configuration {
    name                          = "private-nic"
    subnet_id                     = azurerm_subnet.Jumpbox.id
    private_ip_address_allocation = var.ip_allocation.dynamic
  }
}

resource "azurerm_availability_set" "linux_availability_set" {
  name = local.availability_set_name
  location = var.azure_location
  resource_group_name = module.rg1.name
}