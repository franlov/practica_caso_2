# Create Azure Container Registry

resource "azurerm_container_registry" "franaz-acr" {
  depends_on          = [var.resource_group_name]
  name                = var.container_registry
  resource_group_name = var.resource_group_name
  location            = var.location_name
  sku                 = "Premium"
  admin_enabled       = true

  georeplications {
    location                = "Germany West Central"
    zone_redundancy_enabled = true
    tags                    = {}
  }
}
resource "azurerm_role_assignment" "acrpull_role" {
  scope                            = azurerm_container_registry.franaz-acr.id
  role_definition_name             = "AcrPull"
  principal_id                     = data.azuread_service_principal.aks_principal.id
  skip_service_principal_aad_check = true
}
data "azuread_service_principal" "aks_principal" {
  application_id = var.aks_service_principal_app_id
}
