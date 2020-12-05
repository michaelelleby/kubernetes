variable "resource_group" {
    default = {
        name = "rg-aks-with-keyvault-and-managed-identity"
        location = "East US"
    }
}

variable "kubernetes" {
  default = {
      cluster = {
        name = "testcluster"
        dns_prefix = "exampleaks1"
      },
      identity_name = "my-identity"
  }
}