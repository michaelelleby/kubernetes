resource "random_password" "password" {
  length = 16
  special = true
}

resource "random_string" "identifier_uri" {
  length = 50
  special = false
}

resource "azuread_application" "example" {
  name                       = var.service_principal_name
  homepage                   = "http://homepage"
  identifier_uris            = ["http://${random_string.identifier_uri.result}"]
  reply_urls                 = ["http://replyurl"]
  available_to_other_tenants = false
  oauth2_allow_implicit_flow = true
}

resource "azuread_service_principal" "example" {
  application_id               = azuread_application.example.application_id
  app_role_assignment_required = false
}

resource "azuread_service_principal_password" "example" {
  service_principal_id = azuread_service_principal.example.id
  description          = "My managed password"
  value                = random_password.password.result
  end_date             = "2099-01-01T01:02:03Z"
}