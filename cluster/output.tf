output "public-ip" {
    value = azurerm_public_ip.pip-cluster.ip_address
}