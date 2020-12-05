provider "kubernetes" {
  host = azurerm_kubernetes_cluster.example.kube_config[0].host

  client_key             = base64decode(azurerm_kubernetes_cluster.example.kube_config[0].client_key)
  client_certificate     = base64decode(azurerm_kubernetes_cluster.example.kube_config[0].client_certificate)
  cluster_ca_certificate = base64decode(azurerm_kubernetes_cluster.example.kube_config[0].cluster_ca_certificate)
  load_config_file       = false
}

resource "azurerm_kubernetes_cluster" "example" {
  name                = var.kubernetes.cluster.name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  dns_prefix          = var.kubernetes.cluster.dns_prefix

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

data "azurerm_resource_group" "kubernetes_node_group" {
  name = azurerm_kubernetes_cluster.example.node_resource_group
}

resource "azurerm_user_assigned_identity" "kubernetes" {
  resource_group_name = azurerm_resource_group.rg.name
  location = var.resource_group.location
  name = var.kubernetes.identity_name
}

resource "azurerm_role_assignment" "mir" {
  principal_id = azurerm_kubernetes_cluster.example.kubelet_identity[0].object_id
  role_definition_name = "Managed Identity Operator"
  scope = azurerm_resource_group.rg.id
}

resource "azurerm_role_assignment" "mir_nodegroup" {
  principal_id = azurerm_kubernetes_cluster.example.kubelet_identity[0].object_id
  role_definition_name = "Managed Identity Operator"
  scope = data.azurerm_resource_group.kubernetes_node_group.id
}

resource "azurerm_role_assignment" "vmc_nodegroup" {
  principal_id = azurerm_kubernetes_cluster.example.kubelet_identity[0].object_id
  role_definition_name = "Virtual Machine Contributor"
  scope = data.azurerm_resource_group.kubernetes_node_group.id
}