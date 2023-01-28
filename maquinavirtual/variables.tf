variable "rg_name" {}
variable "rg_location" {}

# Virtual Network
variable "vnet_name" {}
variable "vnet_address_space" {}

# Subnet
variable "subnet_name" {}
variable "subnet_address_prefixes" {}

# Container Registry
variable "acr_name" {}
variable "acr_sku" {}
variable "acr_admin_enabled" {}