variable "azure_location" {
  type        = string
  description = "Region of resources in Azure"
  default     = "East US 2"
}

variable "azure_location_short" {
  type        = string
  description = "Shorthand version of Azure region"
  default     = "eus2"
}

variable "resource_type" {
  type        = map(string)
  description = "Shorthand of resource type"
  default = {
    resource_group         = "rg"
    virtual_network        = "vnet"
    network_security_group = "nsg"
    public_ip              = "pip"
    network_interface      = "nic"
    subnet                 = "snet"
    virtual_machine        = "vm"
    recovery_service_vault = "rsv"
    backup_policy          = "bup"
    key_vault              = "kv"
    load_balancer          = "lb"
    load_balancer_fe       = "lbfe"
    load_balancer_rule     = "lbr"
    load_balancer_probe    = "lbp"
    load_balancer_backend  = "lbbe"
  }
}

variable "subnet" {
  type        = map(string)
  description = "Map of subnet names"
  default = {
    web     = "web"
    data    = "data"
    jumpbox = "jump"
  }
}

variable "web_subnet_address_space" {
  type        = list(string)
  description = "CIDR Notation of web subnet"
  default     = ["10.0.0.0/24"]
}

variable "data_subnet_address_space" {
  type        = list(string)
  description = "CIDR Notation of data subnet"
  default     = ["10.0.1.0/24"]
}

variable "jumpbox_subnet_address_space" {
  type        = list(string)
  description = "CIDR Notation of jumpbox subnet"
  default     = ["10.0.2.0/24"]
}

variable "vnet1_address_space" {
  type        = list(string)
  description = "CIDR Notation of vnet1 network"
  default     = ["10.0.0.0/16"]
}

variable "ip_allocation" {
  type        = map(string)
  description = "Static or Dynamic"
  default = {
    static  = "Static"
    dynamic = "Dynamic"
  }
}

variable "vm_size" {
  type        = map(string)
  description = "VM Sizes"
  default = {
    stan_b1ms = "Standard_B1ms"
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

variable "Windows2019DC" {
  type        = map(string)
  description = "Info for Windows Server 2019 Datacenter"
  default = {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2019-Datacenter"
    version   = "latest"
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

variable "disable_pass_auth" {
  type        = bool
  description = "Disable Password Authentication"
  default     = "false"
}

variable "rsv_sku" {
  type        = string
  description = "Recovery Services Vault SKU"
  default     = "Standard"
}

variable "backup_pol_freq" {
  type        = string
  description = "Frequency of backups"
  default     = "Daily"
}

variable "backup_time" {
  type        = string
  description = "Time of backups"
  default     = "23:00"
}

variable "backups_to_keep" {
  type        = number
  description = "Count of the number of daily backups to keep"
  default     = 30
}

variable "tags" {
  type        = map(string)
  description = "Default Strings"
  default = {
    "managed_by" = "terraform"
    "BU"         = "IT"
  }
}