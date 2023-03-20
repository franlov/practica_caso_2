resource "azurerm_resource_group" "franaz-rg" {
  name     = var.resource_group_name
  location = var.location_name
}