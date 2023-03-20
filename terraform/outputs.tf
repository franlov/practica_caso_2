output "resource_group_id" {
  value     = azurerm_resource_group.franaz-rg.id
  sensitive = true
}

data "azurerm_public_ip" "public_ip" {
  name                = var.public_ip
  resource_group_name = azurerm_resource_group.franaz-rg.name
  depends_on          = [azurerm_resource_group.franaz-rg, azurerm_public_ip.franaz-publicip]
}

output "public_ip" {
  value     = data.azurerm_public_ip.public_ip.*.ip_address
  sensitive = true
}

output "acr_login_server" {
  description = "The URL that can be used to log into the container registry."
  value       = azurerm_container_registry.franaz-acr.login_server
}

data "azurerm_container_registry" "admin_username" {
  name                = var.container_registry
  resource_group_name = azurerm_resource_group.franaz-rg.name
  depends_on          = [azurerm_resource_group.franaz-rg, azurerm_container_registry.franaz-acr]
}

output "admin_username" {
  value     = data.azurerm_container_registry.admin_username.admin_username
  sensitive = true
}

data "azurerm_container_registry" "container_registry" {
  name                = var.container_registry
  resource_group_name = azurerm_resource_group.franaz-rg.name
  depends_on          = [azurerm_resource_group.franaz-rg, azurerm_container_registry.franaz-acr]
}

output "admin_password" {
  value     = data.azurerm_container_registry.container_registry.admin_password
  sensitive = true
}
