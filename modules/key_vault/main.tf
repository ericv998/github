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

resource "azurerm_key_vault_access_policy" "kv_access_policy1" {
  key_vault_id = azurerm_key_vault.key_vault.id
  tenant_id    = data.azurerm_client_config.current.tenant_id
  object_id    = data.azurerm_client_config.current.object_id

  secret_permissions = [
    "Get","Backup","Delete","List","Purge","Recover","Restore","Set",
  ]
}

resource "azurerm_key_vault" "key_vault" {
    name = var.kv_name
    location = var.location
    resource_group_name = var.rg_name
    sku_name = "standard"
    tenant_id = data.azurerm_client_config.current.tenant_id
    enabled_for_deployment = "true"
    tags = var.tags

    lifecycle {
    ignore_changes = [
      # Ignore these settings so that key values and attributes are manually managed
      access_policy
    ]
  }
}

output "id" {
  value = azurerm_key_vault.key_vault.id
}