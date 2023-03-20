variable "resource_group_name" {
  default = "fran-az-rg"
}

variable "resource_group_name_prefix" {
  default = "franaz-aks-"
}

variable "location_name" {
  default = "francecentral"
}

variable "network_name" {
  default = "franaz-vnet1"
}

variable "subnet_name" {
  default = "franaz-subnet1"
}

variable "network_interface" {
  default = "franaz-nic"
}

variable "public_ip" {
  default = "franaz-publicip"
}

variable "security_group" {
  default = "franaz-sgroup"
}

variable "virtual_machine" {
  default = "franaz-vmachine"
}

variable "os_disk" {
  default = "franaz-disco"
}

variable "vm_sku_version" {
  default = "8_5"
}

variable "vm_publisher" {
  default = "OpenLogic"
}
variable "vm_offer" {
  default = "CentOS"
}

variable "vm_version" {
  default = "latest"
}

variable "vm_size" {
  default = "Standard_D2_v2"
}

variable "storage_account_type" {
  default = "Standard_LRS"
}

variable "container_registry" {
  default = "franazcontreg"
}

variable "aks_name" {
  default = "franaz-akscluster"
}

variable "agent_count" {
  default = 1
}

# The following two variable declarations are placeholder references.
# Set the values for these variable in terraform.tfvars
variable "aks_service_principal_app_id" {
  default = "835ebfb4-161f-4a8d-8bd9-19e3c3b28e9d"
}

variable "aks_service_principal_client_secret" {
  default = "Mbf8Q~D-jC.YhkIsov_P-mZ7x96_xc3M_UwF5c63"
}

variable "cluster_name" {
  default = "franaz-k8s-test"
}

variable "dns_prefix" {
  default = "k8s-test"
}

# Refer to https://azure.microsoft.com/global-infrastructure/services/?products=monitor for available Log Analytics regions.
variable "log_analytics_workspace_location" {
  default = "eastus"
}

variable "log_analytics_workspace_name" {
  default = "testLogAnalyticsWorkspaceName"
}

# Refer to https://azure.microsoft.com/pricing/details/monitor/ for Log Analytics pricing
variable "log_analytics_workspace_sku" {
  default = "PerGB2018"
}

variable "ssh_public_key" {
  default = "~/.ssh/id_rsa.pub"
}

variable "computer_name" {
  default = "franaz"
}

variable "admin_vm_username" {
  default = "franlov"
}

variable "admin_aks_username" {
  default = "franlov"
}
