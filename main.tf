# baseline from https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html

#mrg = my resource group - must not exist already according to above page
resource "azurerm_resource_group" "mrg" {
  name     = "hvl71tfcaksrg"
  location = "East US"
}

#maks = my aks
resource "azurerm_kubernetes_cluster" "maks" {
  name                = "hvltfcaks"
  location            = azurerm_resource_group.mrg.location
  resource_group_name = azurerm_resource_group.mrg.name
  dns_prefix          = "hvltfcaks1"

  agent_pool_profile {
    name            = "default"
    count           = 1
    vm_size         = "Standard_D1_v2"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

  service_principal {
    client_id     = "00000000-0000-0000-0000-000000000000"
    client_secret = "00000000000000000000000000000000"
  }

  tags = {
    Environment = "Production"
  }
}

output "client_certificate" {
  value = "${azurerm_kubernetes_cluster.maks.kube_config.0.client_certificate}"
}

output "kube_config" {
  value = "${azurerm_kubernetes_cluster.maks.kube_config_raw}"
}
