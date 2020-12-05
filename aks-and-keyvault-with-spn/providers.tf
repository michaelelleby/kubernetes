provider "azurerm" {
  features {
  }
}

provider "random" {

}

provider "kubernetes" {
  host = azurerm_kubernetes_cluster.example.kube_config[0].host

  client_key             = base64decode(azurerm_kubernetes_cluster.example.kube_config[0].client_key)
  client_certificate     = base64decode(azurerm_kubernetes_cluster.example.kube_config[0].client_certificate)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.example.kube_config[0].cluster_ca_certificate)
  load_config_file       = false
}

provider "azuread" {
}
