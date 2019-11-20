# baseline from https://www.terraform.io/docs/providers/azurerm/r/kubernetes_cluster.html
# altertive: https://www.terraform.io/docs/providers/azurerm/r/virtual_machine.html

# Azure service principal:
# #https://www.terraform.io/docs/providers/azurerm/guides/service_principal_client_secret.html

#other inspirations
#https://github.com/Azure/terraform-azurerm-aks
#https://www.hashicorp.com/blog/kubernetes-cluster-with-aks-and-terraform/

#specify Azure credentials in ~/.bashrc like this - override with your own values
#export ARM_CLIENT_ID="00000000-0000-0000-0000-000000000000"
#export ARM_CLIENT_SECRET="00000000-0000-0000-0000-000000000000"
#export ARM_SUBSCRIPTION_ID="00000000-0000-0000-0000-000000000000"
#export ARM_TENANT_ID="00000000-0000-0000-0000-000000000000"
#export TF_VAR_client_id="000000000000000000000000"
#export TF_VAR_client_secret="0000000000000000000000"
#export TF_VAR_admin_username="0000000000000000000000"
#export TF_VAR_admin_password="0000000000000000000000"

#in TFC environment section specify the same 8 values as environment variables - no quotes in value field as opposed to ~/.bashrc!
#ARM_CLIENT_ID=00000000-0000-0000-0000-000000000000
#ARM_CLIENT_SECRET=00000000-0000-0000-0000-000000000000
#ARM_SUBSCRIPTION_ID=00000000-0000-0000-0000-000000000000
#ARM_TENANT_ID=00000000-0000-0000-0000-000000000000
#TF_VAR_client_id=000000000000000000000000
#TF_VAR_client_secret=0000000000000000000000
#TF_VAR_admin_username=0000000000000000000000
#TF_VAR_admin_password=0000000000000000000000

#the azurerm uses the above settings to authenticate
provider "azurerm" {}

#mrg = my resource group - must not exist already according to above page
resource "azurerm_resource_group" "hvl" {
  name     = "hvl71tfcaksrg02"
  location = "East US"
}

#maks = my aks
resource "azurerm_kubernetes_cluster" "hvl" {
  name                = "hvltfcaks02"
  location            = "${azurerm_resource_group.hvl.location}"
  resource_group_name = "${azurerm_resource_group.hvl.name}"
  dns_prefix          = "hvltfcaks02"

  agent_pool_profile {
    name            = "default"
    count           = 1
    vm_size         = "Standard_D1_v2"
    os_type         = "Linux"
    os_disk_size_gb = 30
  }

agent_pool_profile {
    name            = "win"
    count           = 2
    vm_size         = "Standard_D1_v2"
    os_type         = "Windows"
    os_disk_size_gb = 30
  }

 network_profile {
   network_plugin   = "azure"
 } 

#admin_username and admin_password settings are specified as environment variables
 windows_profile {
   #these variables must be declared (but not set - unless insensitive default values) in variables.tf
    admin_username = "${var.admin_username}"
    admin_password = "${var.admin_password}"
   #admin_username ="azureuser01"
 }

#https://www.terraform.io/docs/configuration/variables.html
#set these 2 settings as environment settings by prefixing with TF_VAR_ in TFC
#that is override values like this:
#export TF_VAR_client_id="00000000-0000-0000-0000-000000000000"
#export TF_VAR_client_secret="00000000000000000000000000000000"
#also declare the 2 variables in variables.tf
#the values were originally created by
#az account list #to get subscription ID (if there is only one)
#az ad sp create-for-rbac --role="Contributor" --scopes="/subscriptions/<subscription-ID>"

  service_principal {
    client_id     = "${var.client_id}"
    client_secret = "${var.client_secret}"
  }

  tags = {
    Environment = "Production"
  }
}

output "client_certificate" {
  value = "${azurerm_kubernetes_cluster.hvl.kube_config.0.client_certificate}"
}

output "kube_config" {
  value = "${azurerm_kubernetes_cluster.hvl.kube_config_raw}"
}
