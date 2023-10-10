resource "azurerm_linux_virtual_machine" "vm-Web-EUS2-001" {
  resource_group_name             = module.rg1.name
  admin_username                  = local.admin_username
  admin_password                  = azurerm_key_vault_secret.admin_pw_lin.value
  location                        = var.azure_location
  name                            = local.web_vm_name
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

resource "azurerm_network_interface" "nic1" {
  name                = local.nic1_name
  location            = var.azure_location
  resource_group_name = module.rg1.name
  tags                = var.tags

  ip_configuration {
    name                          = "public-nic"
    private_ip_address_allocation = var.ip_allocation.dynamic
    subnet_id                     = azurerm_subnet.Web.id
    public_ip_address_id          = azurerm_public_ip.pip1.id
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

resource "azurerm_public_ip" "pip1" {
  name                = local.pip1_name
  resource_group_name = module.rg1.name
  location            = var.azure_location
  allocation_method   = var.ip_allocation.static
  tags                = var.tags
}