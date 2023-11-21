variable "name" {
  description = "Name of the virtual machine"
  type = string
}

variable "location" {
    description = "Azure region"
    type = string
}

variable "resource_group" {
  description = "Resource group name"
  type = string
}

variable "vm_size" {
  description = "SKU of the virtual machine"
  type = string
}

variable "admin_password" {
  description = "Admin Password for Virtual Machine"
  type = string
}

variable "nic_id" {
  description = "Nic to Attach to VM"
  type = string
}

variable "disable_pass_auth" {
  description = "Is Passthrough Authentication Allowed"
  type = bool
  default = false
}

variable "tags" {
  type        = map(string)
  description = "Default Strings"
  default = {
    "managed_by" = "terraform"
    "BU"         = "IT"
  }
}

variable "os_disk" {
  type        = map(string)
  description = "Info os OS disk"
  default = {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }
}

variable "ubuntu22" {
  type        = map(string)
  description = "Info for Ubuntu 22 Image"
  default = {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

variable "avail_set" {
  type = string
  description = "ID of an availability set"
}

resource "azurerm_linux_virtual_machine" "linux_vm" {
  resource_group_name             = var.resource_group
  admin_username                  = "adminev"
  admin_password                  = var.admin_password
  location                        = var.location
  name                            = var.name
  network_interface_ids           = [var.nic_id]
  size                            = var.vm_size
  disable_password_authentication = var.disable_pass_auth
  tags                            = var.tags
  availability_set_id = var.avail_set
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

resource "azurerm_virtual_machine_extension" "nginx" {
  name = "Custom_Script_Ext"
  virtual_machine_id = azurerm_linux_virtual_machine.linux_vm.id
  publisher = "Microsoft.Azure.Extensions"
  type = "CustomScript"
  type_handler_version = "2.1"

  settings = <<SETTINGS
  {
  "commandToExecute": "sudo apt-get update && sudo apt-get -y upgrade && sudo apt-get -y install nginx jq && sudo rm /var/www/html/index.nginx-debian.html && PUBLIC_IPV4=$(curl -H \"metadata:true\" http://169.254.169.254/metadata/instance?api-version=2020-09-01 | jq '.network.interface[0].ipv4.ipAddress[0].publicIpAddress') && HOSTNAME=$(curl -H \"metadata:true\" http://169.254.169.254/metadata/instance?api-version=2020-09-01 | jq '.compute.name') && sudo echo \"<h1> Hello from Virtual Machine $HOSTNAME, with IP Address: $PUBLIC_IPV4</h1>\" > ./index.nginx-debian.html && sudo chown root:root index.nginx-debian.html && sudo cp ./index.nginx-debian.html /var/www/html/index.nginx-debian.html && sudo systemctl restart nginx"
  }
  SETTINGS
}

output "id" {
  value = azurerm_linux_virtual_machine.linux_vm.id
}