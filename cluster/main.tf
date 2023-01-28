resource "azurerm_resource_group" "rg-cluster" {
    name = var.rg_name
    location = var.rg_location
    tags = {
      "resource" = "Cluster"
      "Author" = "HectorZapata"
    }
}

resource "azurerm_public_ip" "pip-cluster" {
    name = "public-ip"
    resource_group_name = azurerm_resource_group.rg-cluster.name
    location = azurerm_resource_group.rg-cluster.location
    allocation_method = "Static"
    tags = {
      "demo" = "sec2"
    }
}

resource "azurerm_virtual_network" "vnet-cluster" {
  name                = "cluster-net"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.rg-cluster.location
  resource_group_name = azurerm_resource_group.rg-cluster.name
}

resource "azurerm_subnet" "subnet-cluster" {
  name                 = "internal"
  resource_group_name  = azurerm_resource_group.rg-cluster.name
  virtual_network_name = azurerm_virtual_network.vnet-cluster.name
  address_prefixes     = ["10.0.2.0/24"]
}

resource "azurerm_network_interface" "netinter-cluster" {
  name                = "networkinterfacecluster"
  location            = azurerm_resource_group.rg-cluster.location
  resource_group_name = azurerm_resource_group.rg-cluster.name
  ip_configuration {
    name                          = "internal"
    subnet_id                     = azurerm_subnet.subnet-cluster.id
    private_ip_address_allocation = "Dynamic"
    public_ip_address_id = azurerm_public_ip.pip-cluster.id
  }
}

resource "azurerm_container_registry" "acr-cluster" {
    name = var.acr_name
    resource_group_name = azurerm_resource_group.rg-cluster.name
    location = azurerm_resource_group.rg-cluster.location
    sku = var.acr_sku
    admin_enabled = var.acr_admin_enabled
}

resource "azurerm_kubernetes_cluster" "aks-cluster" {
    name = var.aks_name
    location = azurerm_resource_group.rg-cluster.location
    resource_group_name = azurerm_resource_group.rg-cluster.name
    dns_prefix = var.aks_dns_prefix
    kubernetes_version = var.aks_kubernetes_version
    role_based_access_control_enabled = var.aks_rbac_enabled

    default_node_pool {
      name = var.aks_np_name
      node_count = var.aks_np_node_count
      vm_size = var.aks_np_vm_size
      vnet_subnet_id = azurerm_subnet.subnet-cluster.id
      enable_auto_scaling = var.aks_np_enabled_auto_scaling
      max_count = var.aks_np_max_count
      min_count = var.aks_np_min_count
    }

    service_principal {
      client_id = var.aks_sp_client_id
      client_secret = var.aks_sp_client_secret
    }
  
  network_profile {
    network_plugin = var.aks_net_plugin
    network_policy = var.aks_net_policy
  }
}

resource "azurerm_kubernetes_cluster_node_pool" "example" {
  name                  = "internal"
  kubernetes_cluster_id = azurerm_kubernetes_cluster.aks-cluster.id
  vm_size               = var.aks_np_vm_size
  node_count            = 1

  tags = {
    label = "Adicional"
  }
}