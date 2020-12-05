resource "azurerm_kubernetes_cluster" "example" {
  name                = "example-aks1"
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = "exampleaks1"

  default_node_pool {
    name       = "default"
    node_count = 1
    vm_size    = "Standard_B2s"
  }

  identity {
    type = "SystemAssigned"
  }

  network_profile {
    network_plugin = "azure"
  }
}

resource "kubernetes_secret" "example" {
  metadata {
    name = "secrets-store-creds"
  }

  data = {
    clientid     = azuread_application.example.application_id
    clientsecret = azuread_service_principal_password.example.value
  }
}
