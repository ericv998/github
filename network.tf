resource "azurerm_virtual_network" "vnet1" {
  name                = local.vnet1_name
  resource_group_name = module.rg1.name
  address_space       = var.vnet1_address_space
  location            = var.azure_location
  tags                = var.tags
}

resource "azurerm_subnet" "Web" {
  name                 = local.web_subnet_name
  address_prefixes     = var.web_subnet_address_space
  resource_group_name  = module.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
}

resource "azurerm_subnet" "Data" {
  name                 = local.data_subnet_name
  address_prefixes     = var.data_subnet_address_space
  resource_group_name  = module.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
}

resource "azurerm_subnet" "Jumpbox" {
  name                 = local.jump_subnet_name
  address_prefixes     = var.jumpbox_subnet_address_space
  resource_group_name  = module.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
}

resource "azurerm_network_interface_security_group_association" "nsgassoc1" {
  count = var.linux_vm_count
  network_interface_id      = azurerm_network_interface.linux_nics[count.index].id
  network_security_group_id = azurerm_network_security_group.nsg1.id
}

resource "azurerm_network_security_group" "nsg1" {
  name                = local.nsg_name
  location            = var.azure_location
  resource_group_name = module.rg1.name
  tags                = var.tags

  security_rule {
    name = "Port80Inbound"
    priority = 100
    direction = "Inbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = "*"
    destination_port_range = 80
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    name = "Port80Outbound"
    priority = 110
    direction = "Outbound"
    access = "Allow"
    protocol = "Tcp"
    source_port_range = 80
    destination_port_range = "*"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}