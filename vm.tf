provider "azurerm" {
  features {}
}

resource "azurerm_resource_group" "LBANDDNS" {
  name     = "Testlbanddns"
  location = "Central US"
}

resource "azurerm_virtual_network" "lbdns" {
  name                = "lbdns-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.LBANDDNS.location
  resource_group_name = azurerm_resource_group.LBANDDNS.name
}

resource "azurerm_subnet" "sub1" {
  name                 = "Subnet1"
  resource_group_name  = azurerm_resource_group.LBANDDNS.name
  virtual_network_name = azurerm_virtual_network.lbdns.name
  address_prefixes     = ["10.0.11.0/24"]
}  

resource "azurerm_subnet" "sub2" {
  name                 = "Subnet2"
  resource_group_name  = azurerm_resource_group.LBANDDNS.name
  virtual_network_name = azurerm_virtual_network.lbdns.name
  address_prefixes     = ["10.0.12.0/24"]
}  

resource "azurerm_network_interface" "ntin" {
  name                = "ntinlbdns"
  location            = azurerm_resource_group.LBANDDNS.location
  resource_group_name = azurerm_resource_group.LBANDDNS.name

  ip_configuration {
    name                          = "lbdnsip1"
    subnet_id                     = azurerm_subnet.sub1.id
    private_ip_address_allocation = "Dynamic"
    sku = "Standard"
    sku_tier = "Regional"
  }
}

resource "azurerm_windows_virtual_machine" "SpkMachine" {
  name                = "SpokeMachine"
  resource_group_name = azurerm_resource_group.LBANDDNS.name
  location            = azurerm_resource_group.LBANDDNS.location
  size                = "Standard_F2"
  admin_username      = "Windows"
  admin_password      = "Windows@12345"
  network_interface_ids = [
    azurerm_network_interface.NtwrkIntrfce.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "MicrosoftWindowsServer"
    offer     = "WindowsServer"
    sku       = "2016-Datacenter"
    version   = "latest"
  }
}
