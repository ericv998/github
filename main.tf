resource "azurerm_resource_group" "rg1" {
  name     = "rg-eus2"
  location = "East US 2"
}

resource "azurerm_subnet" "Web" {
  name                 = "Web"
  address_prefixes     = ["10.0.0.0/24"]
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
}

resource "azurerm_subnet" "Data" {
  name                 = "Data"
  address_prefixes     = ["10.0.1.0/24"]
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
}

resource "azurerm_subnet" "Jumpbox" {
  name                 = "Jumpbox"
  address_prefixes     = ["10.0.2.0/24"]
  resource_group_name  = azurerm_resource_group.rg1.name
  virtual_network_name = azurerm_virtual_network.vnet1.name
}

resource "azurerm_network_interface_security_group_association" "nsgassoc1" {
  network_interface_id      = azurerm_network_interface.nic1.id
  network_security_group_id = azurerm_network_security_group.nsg1.id
}

resource "azurerm_virtual_network" "vnet1" {
  name                = "vnet-eus2"
  resource_group_name = azurerm_resource_group.rg1.name
  address_space       = ["10.0.0.0/16"]
  location            = "East US 2"
}

resource "azurerm_network_security_group" "nsg1" {
  name                = "nsg-web-eus2-001"
  location            = "East US 2"
  resource_group_name = azurerm_resource_group.rg1.name
}

resource "azurerm_public_ip" "pip1" {
  name                = "pip-eus2-001"
  resource_group_name = azurerm_resource_group.rg1.name
  location            = "East US 2"
  allocation_method   = "Static"
}

resource "azurerm_network_interface" "nic1" {
  name                = "nic-eus2-001"
  location            = "East US 2"
  resource_group_name = azurerm_resource_group.rg1.name

  ip_configuration {
    name                          = "public-nic"
    private_ip_address_allocation = "Dynamic"
    subnet_id                     = azurerm_subnet.Web.id
    public_ip_address_id          = azurerm_public_ip.pip1.id
  }
}

resource "azurerm_network_interface" "nic2" {
  name                = "nic-eus2-002"
  location            = "East US 2"
  resource_group_name = azurerm_resource_group.rg1.name

  ip_configuration {
    name                          = "private-nic"
    subnet_id                     = azurerm_subnet.Jumpbox.id
    private_ip_address_allocation = "Dynamic"
  }
}

resource "azurerm_linux_virtual_machine" "vm-Web-EUS2-001" {
  resource_group_name   = azurerm_resource_group.rg1.name
  admin_username        = "evadmin"
  admin_password =  "Testtest1"
  location              = "East US 2"
  name                  = "VM-WEB-EUS2-001"
  network_interface_ids = [azurerm_network_interface.nic1.id]
  size                  = "Standard_B1ms"
  disable_password_authentication = "false"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

resource "azurerm_windows_virtual_machine" "vm-jump-eus2-01" {
  resource_group_name   = azurerm_resource_group.rg1.name
  admin_username        = "evadmin"
  admin_password        = "Testtest1"
  location              = "East US 2"
  name                  = "VM-JUMP-EUS2-01"
  network_interface_ids = [azurerm_network_interface.nic2.id]
  size                  = "Standard_B1ms"
  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
  }
}