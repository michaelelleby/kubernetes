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

resource "helm_release" "pod-identity" {
  name = "aad-pod-identity"
  repository = "https://raw.githubusercontent.com/Azure/aad-pod-identity/master/charts"
  chart = "aad-pod-identity"

  set {
    name = "azureIdentities.0.name"
    value = "azure-identity"
  }

  set {
    name = "azureIdentities.0.type"
    value = "0"
  }

  set {
    name = "azureIdentities.0.resourceID"
    value = azurerm_user_assigned_identity.kubernetes.id
  }

  set {
    name = "azureIdentities.0.clientID"
    value = azurerm_user_assigned_identity.kubernetes.client_id
  }

  set {
    name = "azureIdentities.0.binding.name"
    value = "azure-identity-binding"
  }

  set {
    name = "azureIdentities.0.binding.selector"
    value = "azure-pod-identity-binding-selector"
  }
}

resource "helm_release" "secretprovider" {
  name  = "mysecretproviderrelease"
  chart = "helm"

  depends_on = [ 
    helm_release.pod-identity
   ]

  set {
    name  = "client_id"
    value = azurerm_user_assigned_identity.kubernetes.client_id
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
