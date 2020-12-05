provider "helm" {
  kubernetes {
    host = azurerm_kubernetes_cluster.example.kube_config[0].host

    client_key             = base64decode(azurerm_kubernetes_cluster.example.kube_config[0].client_key)
    client_certificate     = base64decode(azurerm_kubernetes_cluster.example.kube_config[0].client_certificate)
    cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.example.kube_config[0].cluster_ca_certificate)
    load_config_file       = false
  }
}

resource "helm_release" "csi-keyvault-provider" {
  name       = "keyvault-provider"
  repository = "https://raw.githubusercontent.com/Azure/secrets-store-csi-driver-provider-azure/master/charts"
  chart      = "csi-secrets-store-provider-azure"
}

resource "helm_release" "secretprovider" {
  name  = "mysecretproviderrelease"
  chart = "helm"

  set {
    name  = "client_id"
    value = azuread_service_principal.example.application_id
  }

  set {
    name  = "keyvault_name"
    value = azurerm_key_vault.vault.name
  }

  set {
    name  = "secret_name"
    value = azurerm_key_vault_secret.example.name
  }

  set {
    name  = "resource_group"
    value = azurerm_resource_group.rg.name
  }

  set {
    name  = "subscription_id"
    value = data.azurerm_client_config.current.subscription_id
  }

  set {
    name  = "tenant_id"
    value = data.azurerm_client_config.current.tenant_id
  }
}
