variable "name" {
    description = "Resource Group Name"
    type = string
}

variable "location" {
    description = "Azure region for resource group"
    type = string
}

variable "tags" {
    description = "Tags for resource group"
    type = map(string)
}

resource "azurerm_resource_group" "rg" {
    name = var.name
    location = var.location
    tags = var.tags
}

output "name" {
    value =azurerm_resource_group.rg.name
}

output "location" {
    value = azurerm_resource_group.rg.location
}

output "id" {
    value = azurerm_resource_group.rg.id
}