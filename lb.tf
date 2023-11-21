resource "azurerm_public_ip" "pip1" {
  name                = local.pip1_name
  resource_group_name = module.rg1.name
  location            = var.azure_location
  allocation_method   = var.ip_allocation.static
  tags                = var.tags
}

module "lb" {
  source           = "./modules/load_balancer"
  name             = local.lb_name
  location         = var.azure_location
  rg_name          = module.rg1.name
  public_ip_id        = azurerm_public_ip.pip1.id
  frontend_ip_name = local.frontend_ip_name
}

resource "azurerm_lb_rule" "lb_rule1" {
  loadbalancer_id                = module.lb.lb_id
  name                           = local.lb_rule1_name
  frontend_ip_configuration_name = local.frontend_ip_name
  protocol                       = "Tcp"
  frontend_port                  = 80
  backend_port                   = 80
  probe_id = azurerm_lb_probe.lb_probe1.id
  backend_address_pool_ids = [azurerm_lb_backend_address_pool.lb_backend1.id]
}

resource "azurerm_lb_probe" "lb_probe1" {
  loadbalancer_id = module.lb.lb_id
  name            = local.lb_probe1_name
  port            = 80
}

resource "azurerm_lb_backend_address_pool" "lb_backend1" {
  name            = local.lb_backend_pool1
  loadbalancer_id = module.lb.lb_id
}

resource "azurerm_network_interface_backend_address_pool_association" "nic_backend1" {
  count = var.linux_vm_count
  network_interface_id    = azurerm_network_interface.linux_nics[count.index].id
  backend_address_pool_id = azurerm_lb_backend_address_pool.lb_backend1.id
  ip_configuration_name   = "private-nic"
}