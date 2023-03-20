# Create (and display) an SSH key
resource "tls_private_key" "franaz-ssh" {
  algorithm = "RSA"
  rsa_bits  = 4096
}

# Create virtual machine
resource "azurerm_linux_virtual_machine" "franaz-vm" {
  name                  = var.virtual_machine
  location              = azurerm_resource_group.franaz-rg.location
  resource_group_name   = azurerm_resource_group.franaz-rg.name
  network_interface_ids = [azurerm_network_interface.franaz-nic.id]
  size                  = var.vm_size

  os_disk {
    name                 = var.os_disk
    caching              = "ReadWrite"
    storage_account_type = var.storage_account_type
  }

  source_image_reference {
    publisher = var.vm_publisher
    offer     = var.vm_offer
    sku       = var.vm_sku_version
    version   = var.vm_version
  }

  computer_name                   = var.computer_name
  admin_username                  = var.admin_vm_username
  disable_password_authentication = true

  admin_ssh_key {
    username   = var.admin_vm_username
    public_key = file("~/.ssh/id_rsa.pub")
  }

}
