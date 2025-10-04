terraform {
  required_version = ">= 1.5.0"
  
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = ">= 4.40.0, < 5.0.0"
    }
    random = {
      source  = "hashicorp/random"
      version = ">= 3.6.0"
    }
  }
}


provider "azurerm" {
  features {}

  subscription_id = var.subscription_id
  client_id       = var.client_id
  client_secret   = var.client_secret
  tenant_id       = var.tenant_id
}

variable "subscription_id" { type = string }
variable "client_id" { type = string }
variable "client_secret" { type = string, sensitive = true }
variable "tenant_id" { type = string }

variable "location" {
  type        = string
  default     = "Canada Central"
  description = "Azure region for all resources"
}

variable "publisher_name" {
  type    = string
  default = "Your Company"
}

variable "publisher_email" {
  type    = string
  default = "admin@mcit.com"
}

resource "random_string" "apim_suffix" {
  length  = 5
  upper   = false
  numeric = true
  special = false
}

locals {
  rg_name   = "rg-apim-product-mcit"
  apim_name = "mcit-apim-${random_string.apim_suffix.result}"

  apis = {
    api1 = { display_name = "API One",   path = "api-one"   }
    api2 = { display_name = "API Two",   path = "api-two"   }
    api3 = { display_name = "API Three", path = "api-three" }
    api4 = { display_name = "API Four",  path = "api-four"  }
    api5 = { display_name = "API Five",  path = "api-five"  }
  }

  mcit_openapi_url = "https://petstore.swagger.io/v2/swagger.json"
}

resource "azurerm_resource_group" "rg" {
  name     = local.rg_name
  location = var.location
}

resource "azurerm_api_management" "apim" {
  name                = local.apim_name
  location            = azurerm_resource_group.rg.location
  resource_group_name = azurerm_resource_group.rg.name
  publisher_name      = var.publisher_name
  publisher_email     = var.publisher_email
  sku_name            = "Developer_1"
}

resource "azurerm_api_management_product" "starter" {
  product_id            = "starter"
  api_management_name   = azurerm_api_management.apim.name
  resource_group_name   = azurerm_resource_group.rg.name
  display_name          = "Starter Product"
  description           = "A starter product with mcit APIs."
  subscription_required = true
  approval_required     = false
  published             = true
}

resource "azurerm_api_management_api" "apis" {
  for_each            = local.apis
  name                = each.key
  resource_group_name = azurerm_resource_group.rg.name
  api_management_name = azurerm_api_management.apim.name
  revision            = "1"
  display_name        = each.value.display_name
  path                = each.value.path
  protocols           = ["https"]

  import {
    content_format = "swagger-link-json"
    content_value  = local.mcit_openapi_url
  }
}

resource "azurerm_api_management_product_api" "starter_apis" {
  for_each            = azurerm_api_management_api.apis
  api_name            = each.value.name
  product_id          = azurerm_api_management_product.starter.product_id
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.rg.name
}

resource "azurerm_api_management_user" "dev" {
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.rg.name
  user_id             = "mcit-dev"
  first_name          = "Mcit"
  last_name           = "Developer"
  email               = "developer@mcit.com"
  state               = "active"
}

resource "azurerm_api_management_subscription" "starter_sub" {
  display_name        = "Starter Subscription"
  api_management_name = azurerm_api_management.apim.name
  resource_group_name = azurerm_resource_group.rg.name
  product_id          = azurerm_api_management_product.starter.id
  user_id             = azurerm_api_management_user.dev.id
}

output "apim_gateway_base_url" {
  description = "Gateway base URL"
  value       = "https://${azurerm_api_management.apim.gateway_url}"
}

output "apim_developer_portal_url" {
  description = "Developer portal URL"
  value       = azurerm_api_management.apim.developer_portal_url
}

output "product_id" {
  description = "APIM product ID"
  value       = azurerm_api_management_product.starter.product_id
}

output "api_names" {
  description = "APIs created"
  value       = [for a in azurerm_api_management_api.apis : a.name]
}

output "subscription_primary_key" {
  description = "Primary key for the mcit subscription"
  sensitive   = true
  value       = azurerm_api_management_subscription.starter_sub.primary_key
}

