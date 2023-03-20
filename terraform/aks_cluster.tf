# Create a kubernetes cluster
resource "azurerm_kubernetes_cluster" "franaz-k8s" {
  location            = var.location_name
  name                = var.cluster_name
  resource_group_name = var.resource_group_name
  dns_prefix          = var.dns_prefix
  tags = {

    Environment = "Casopractico2"
  }

  default_node_pool {
    name       = "agentpool"
    vm_size    = "Standard_DS2_v2"
    node_count = var.agent_count
  }
  linux_profile {
    admin_username = var.admin_aks_username

    ssh_key {
      key_data = file(var.ssh_public_key)
    }
  }
  network_profile {
    network_plugin    = "kubenet"
    load_balancer_sku = "standard"
  }
  service_principal {
    client_id     = var.aks_service_principal_app_id
    client_secret = var.aks_service_principal_client_secret
  }

}