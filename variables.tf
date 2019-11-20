variable "admin_username" {
  default     = "azureuser"
  description = "The username of the local administrator to be created on the Kubernetes cluster"
}

variable "admin_password" {
  description = "The password of the local administrator to be created on the Kubernetes cluster"
}

variable "client_id" {
  description ="This is the client ID"
}

variable "client_secret" {
}