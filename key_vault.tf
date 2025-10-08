


###############################################
# 🔹 VARIABLES
###############################################

variable "location2" {
  type    = string
  default = "Canada Central"
}

variable "prefix" {
  type    = string
  default = "montrealitcollege"
}

# Deux tenant_id distincts
variable "tenant_id_keyvault" {
  type        = string
  description = "AAD tenant ID utilisé pour le Key Vault"
}

variable "tenant_id_ml" {
  type        = string
  description = "AAD tenant ID utilisé pour le Machine Learning Workspace et les Access Policies"
}

###############################################
# 🔹 RANDOM STRING
###############################################

resource "random_string" "suffix" {
  length  = 6
  upper   = false
  special = false
}

###############################################
# 🔹 RESOURCE GROUP
###############################################

resource "azurerm_resource_group" "ml_rg" {
  name     = "${var.prefix}-rg"
  location = var.location2
}

###############################################
# 🔹 STORAGE ACCOUNT
###############################################

resource "azurerm_storage_account" "ml_storage" {
  name                     = substr(lower("${var.prefix}st${random_string.suffix.result}"),0,24)
  resource_group_name      = azurerm_resource_group.ml_rg.name
  location                 = var.location2
  account_tier             = "Standard"
  account_replication_type = "LRS"
}

###############################################
# 🔹 KEY VAULT
###############################################

resource "azurerm_key_vault" "ml_kv" {
  name                        = "${var.prefix}kv${random_string.suffix.result}"
  resource_group_name         = azurerm_resource_group.ml_rg.name
  location                    = var.location2
  tenant_id                   = var.tenant_id_keyvault
  sku_name                    = "standard"
  purge_protection_enabled    = true
  soft_delete_retention_days  = 7
}

###############################################
# 🔹 APPLICATION INSIGHTS
###############################################

resource "azurerm_application_insights" "ml_appi" {
  name                = "${var.prefix}-appi"
  location            = var.location2
  resource_group_name = azurerm_resource_group.ml_rg.name
  application_type    = "web"
}

###############################################
# 🔹 CONTAINER REGISTRY
###############################################

resource "azurerm_container_registry" "ml_acr" {
  name                = "${var.prefix}acr${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.ml_rg.name
  location            = var.location2
  sku                 = "Basic"
  admin_enabled       = true
}

###############################################
# 🔹 MACHINE LEARNING WORKSPACE
###############################################

resource "azurerm_machine_learning_workspace" "ml_ws" {
  name                          = "${var.prefix}-ws"
  location                      = var.location2
  resource_group_name           = azurerm_resource_group.ml_rg.name
  storage_account_id            = azurerm_storage_account.ml_storage.id
  key_vault_id                  = azurerm_key_vault.ml_kv.id
  application_insights_id       = azurerm_application_insights.ml_appi.id
  container_registry_id         = azurerm_container_registry.ml_acr.id
  public_network_access_enabled = true

  identity {
    type = "SystemAssigned"
  }

  description = "Terraform-provisioned Azure ML workspace"
}

###############################################
# 🔹 KEY VAULT ACCESS POLICY
###############################################

resource "azurerm_key_vault_access_policy" "ml_kv_policy" {
  key_vault_id = azurerm_key_vault.ml_kv.id
  tenant_id    = var.tenant_id_ml
  object_id    = azurerm_machine_learning_workspace.ml_ws.identity[0].principal_id

  secret_permissions      = ["Get", "List", "Set", "Delete", "Purge", "Recover", "Backup", "Restore"]
  key_permissions         = ["Get", "Create", "Delete", "List"]
  certificate_permissions = ["Get", "List"]
}

###############################################
# 🔹 COMPUTE CLUSTER
###############################################

resource "azurerm_machine_learning_compute_cluster" "ml_cpu" {
  name                = "${var.prefix}-cpu"
  location            = var.location2
  resource_group_name = azurerm_resource_group.ml_rg.name
  workspace_name      = azurerm_machine_learning_workspace.ml_ws.name

  vm_size = "STANDARD_DS3_V2"

  scale_settings {
    min_node_count = 0
    max_node_count = 1
  }
}

###############################################
# 🔹 OUTPUTS
###############################################

output "resource_group" {
  value = azurerm_resource_group.ml_rg.name
}

output "workspace_name" {
  value = azurerm_machine_learning_workspace.ml_ws.name
}

output "storage_account" {
  value = azurerm_storage_account.ml_storage.name
}

output "container_registry" {
  value = azurerm_container_registry.ml_acr.name
}
