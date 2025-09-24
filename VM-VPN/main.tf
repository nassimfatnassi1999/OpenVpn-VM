terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "=3.75.0"
    }
  }
}
provider "azurerm" {
  features {
    resource_group {
      prevent_deletion_if_contains_resources = false
    }
  }
  skip_provider_registration = true
}

resource "azurerm_resource_group" "vpn_rg" {
  name     = "vpn-rg"
  location = "francecentral"
}

resource "azurerm_virtual_network" "vpn_vnet" {
  name                = "vpn-vnet"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.vpn_rg.location
  resource_group_name = azurerm_resource_group.vpn_rg.name
}

resource "azurerm_subnet" "vpn_subnet" {
  name                 = "vpn-subnet"
  resource_group_name  = azurerm_resource_group.vpn_rg.name
  virtual_network_name = azurerm_virtual_network.vpn_vnet.name
  address_prefixes     = ["10.0.1.0/24"]
}

resource "azurerm_network_interface" "vpn_nic" {
  name                = "vpn-nic"
  location            = azurerm_resource_group.vpn_rg.location
  resource_group_name = azurerm_resource_group.vpn_rg.name

  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.vpn_subnet.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id           = azurerm_public_ip.vpn_public_ip.id
  }
}

resource "azurerm_public_ip" "vpn_public_ip" {
  name                = "vpn-pip"
  location            = azurerm_resource_group.vpn_rg.location
  resource_group_name = azurerm_resource_group.vpn_rg.name
  allocation_method   = "Static"
}

resource "azurerm_linux_virtual_machine" "vpn_vm" {
  name                = "openvpn-vm"
  resource_group_name = azurerm_resource_group.vpn_rg.name
  location            = azurerm_resource_group.vpn_rg.location
  size                = "Standard_B2s"
  admin_username      = "azureuser"
  network_interface_ids = [
    azurerm_network_interface.vpn_nic.id
  ]

  admin_ssh_key {
    username   = "azureuser"
    public_key = file("/home/nassimfh/.ssh/id_rsa.pub")
  }

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "0001-com-ubuntu-server-jammy"
    sku       = "22_04-lts-gen2"
    version   = "latest"
  }
}

output "vpn_private_ip" {
  value = azurerm_network_interface.vpn_nic.private_ip_address
}

output "vpn_public_ip" {
  value = azurerm_public_ip.vpn_public_ip.ip_address
}
