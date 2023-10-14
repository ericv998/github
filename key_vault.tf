module "kv1" {
  source   = "./modules/key_vault"
  kv_name  = local.kv1_name
  location = var.azure_location
  rg_name  = module.rg1.name
  tags     = var.tags
}

resource "random_password" "admin_password_linux" {
  length = 16
}

resource "random_password" "admin_password_windows" {
  length = 16
}

resource "azurerm_key_vault_secret" "admin_pw_win" {
  name         = "windows-admin-pw"
  value        = random_password.admin_password_windows.result
  key_vault_id = module.kv1.id
}

resource "azurerm_key_vault_secret" "admin_pw_lin" {
  name         = "linux-admin-pw"
  value        = random_password.admin_password_linux.result
  key_vault_id = module.kv1.id
}