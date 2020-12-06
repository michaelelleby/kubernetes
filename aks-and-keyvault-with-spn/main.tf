data "azurerm_client_config" "current" {}

resource "random_password" "secret" {
  length = 16
  special = true
}

resource "random_string" "keyvault_name" {
  length = 20
  override_special = "-"
}

resource "azurerm_resource_group" "rg" {
  name     = var.resource_group.name
  location = var.resource_group.location
}

resource "azurerm_key_vault" "vault" {
  name = random_string.keyvault_name.result
  resource_group_name = azurerm_resource_group.rg.name
  location = azurerm_resource_group.rg.location
  tenant_id = data.azurerm_client_config.current.tenant_id

  sku_name = "standard"
}

resource "azurerm_key_vault_access_policy" "user" {
  key_vault_id = azurerm_key_vault.vault.id
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = data.azurerm_client_config.current.object_id
  
  secret_permissions = [
      "get",
      "set",
      "list",
      "delete",
  ]
}

resource "azurerm_key_vault_secret" "example" {
  name         = "secret-sauce"
  value        = random_password.secret.result
  key_vault_id = azurerm_key_vault.vault.id
  
  depends_on = [  
    azurerm_key_vault_access_policy.user
  ]
}

resource "azurerm_role_assignment" "reader" {
  scope = azurerm_resource_group.rg.id
  role_definition_name = "Reader"
  principal_id = azuread_service_principal.example.object_id
}

resource "azurerm_key_vault_access_policy" "sp" {
  key_vault_id = azurerm_key_vault.vault.id
  tenant_id = data.azurerm_client_config.current.tenant_id
  object_id = azuread_service_principal.example.object_id
  
  secret_permissions = [
      "get",
  ]

  key_permissions = [
    "get",
  ]
}
