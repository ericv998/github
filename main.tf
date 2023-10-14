module "rg1" {
  source   = "./modules/resource_group"
  name     = local.rg1_name
  location = var.azure_location
  tags     = var.tags
}