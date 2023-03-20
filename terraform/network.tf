# Create virtual network
resource "azurerm_virtual_network" "franaz-virnet" {
  name                = var.network_name
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.franaz-rg.location
  resource_group_name = azurerm_resource_group.franaz-rg.name
}

# Create subnet
resource "azurerm_subnet" "franaz-sub" {
  name                 = var.subnet_name
  resource_group_name  = azurerm_resource_group.franaz-rg.name
  virtual_network_name = azurerm_virtual_network.franaz-virnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

# Create network interface
resource "azurerm_network_interface" "franaz-nic" {
  name                = var.network_interface
  location            = azurerm_resource_group.franaz-rg.location
  resource_group_name = azurerm_resource_group.franaz-rg.name

  ip_configuration {
    name                          = "testipconf"
    subnet_id                     = azurerm_subnet.franaz-sub.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id          = azurerm_public_ip.franaz-publicip.id
  }
}

# Create public IPs
resource "azurerm_public_ip" "franaz-publicip" {
  name                = var.public_ip
  location            = azurerm_resource_group.franaz-rg.location
  resource_group_name = azurerm_resource_group.franaz-rg.name
  allocation_method   = "Dynamic"

}

# Create Network Security Group and rule
resource "azurerm_network_security_group" "franaz-aznsg" {
  name                = var.security_group
  location            = azurerm_resource_group.franaz-rg.location
  resource_group_name = azurerm_resource_group.franaz-rg.name

  security_rule {
    #Allow ssh traffic from private subnet to Internet
    name                       = "SSH"
    priority                   = 1001
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "22"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    #Allow http traffic from private subnet to Internet
    name                       = "allow-http-all"
    priority                   = 110
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "80"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }

  security_rule {
    #Allow https traffic from private subnet to Internet
    name                       = "allow-https-all"
    priority                   = 111
    direction                  = "Inbound"
    access                     = "Allow"
    protocol                   = "Tcp"
    source_port_range          = "*"
    destination_port_range     = "443"
    source_address_prefix      = "*"
    destination_address_prefix = "*"
  }
}

# Connect the security group to the network interface
resource "azurerm_network_interface_security_group_association" "franaz-anisg" {
  network_interface_id      = azurerm_network_interface.franaz-nic.id
  network_security_group_id = azurerm_network_security_group.franaz-aznsg.id
}
