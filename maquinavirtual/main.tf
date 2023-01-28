resource "azurerm_resource_group" "rg-jenkins" {
    name = var.rg_name
    location = var.rg_location
    tags = {
      "Instalar" = "Jenkins"
      "Author" = "HectorZapata"
    }
}

resource "azurerm_public_ip" "pip-jenkins" {
    name = "public-ip"
    resource_group_name = azurerm_resource_group.rg-jenkins.name
    location = azurerm_resource_group.rg-jenkins.location
    allocation_method = "Static"
    tags = {
      "demo" = "sec2"
    }
}

resource "azurerm_virtual_network" "vnet-jenkins" {
  name                = "jenkins-net"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg-jenkins.location
  resource_group_name = azurerm_resource_group.rg-jenkins.name
}

resource "azurerm_subnet" "subnet-jenkins" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg-jenkins.name
  virtual_network_name = azurerm_virtual_network.vnet-jenkins.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "netinter-jenkins" {
  name                = "networkinterface"
  location            = azurerm_resource_group.rg-jenkins.location
  resource_group_name = azurerm_resource_group.rg-jenkins.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet-jenkins.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip-jenkins.id
  }
}

resource "azurerm_linux_virtual_machine" "vm-jenkins" {
  name                = "demo-machine"
  resource_group_name = azurerm_resource_group.rg-jenkins.name
  location            = azurerm_resource_group.rg-jenkins.location
  size                = "Standard_B1s"
 
  network_interface_ids = [
    azurerm_network_interface.netinter-jenkins.id,
  ]

  os_disk {
    caching              = "ReadWrite"
    storage_account_type = "Standard_LRS"
  }

  source_image_reference {
    publisher = "Canonical"
    offer     = "UbuntuServer"
    sku       = "16.04-LTS"
    version   = "latest"
  }

    computer_name = "hostname"
    admin_username = "testadmin"
    admin_password = "Diplomado$ec2"
    disable_password_authentication = false
}

resource "azurerm_container_registry" "acr-jenkins" {
    name = var.acr_name
    resource_group_name = azurerm_resource_group.rg-jenkins.name
    location = azurerm_resource_group.rg-jenkins.location
    sku = var.acr_sku
    admin_enabled = var.acr_admin_enabled
}