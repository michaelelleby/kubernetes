variable "service_principal_name" {
    default = "contosoServicePrincipal"
}

variable "resource_group" {
    default = {
        name = "rg-aks-with-keyvault-and-spn"
        location = "East US"
    }
}