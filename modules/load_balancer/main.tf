variable "name" {
    description = "Load balancer name"
    type = string
}

variable "location" {
    description = "Azure region for load balancer"
    type = string
}

variable "rg_name" {
    description = "Resource group name"
    type = string
}

variable "frontend_ip_name" {
    description = "Frontend lb name"
    type = string
}

variable "public_ip_id" {
    description = "Public ip address ID for the front end lb"
    type = string
}

resource "azurerm_lb" "public_lb" {
    name = var.name
    location = var.location
    resource_group_name = var.rg_name
    frontend_ip_configuration {
      name = var.frontend_ip_name
      public_ip_address_id = var.public_ip_id
    }
}

output "lb_id" {
  value       = azurerm_lb.public_lb.id
  description = "Load Balancer ID"
}