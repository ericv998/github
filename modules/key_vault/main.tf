variable "kv_name" {
    description = "Key Vault Name"
    type = string
}

variable "location" {
    description = "Azure region for resource group"
    type = string
}

variable "rg_name" {
    description = "Resource group name"
    type = string
}

data "azurerm_client_config" "current" {}

variable "tags" {
    description = "Key vault tags"
    type = map(string)
}

resource "azurerm_key_vault" "key_vault" {
    name = var.kv_name
    location = var.location
    resource_group_name = var.rg_name
    sku_name = "standard"
    tenant_id = data.azurerm_client_config.current.tenant_id
    enabled_for_deployment = "true"
    tags = var.tags
}