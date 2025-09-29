# Outputs for the Terraform configuration
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "resource_group_id" {
  description = "ID of the resource group"
  value       = azurerm_resource_group.main.id
}

output "databricks_workspace_id" {
  description = "ID of the Databricks workspace"
  value       = azurerm_databricks_workspace.main.id
}

output "databricks_workspace_url" {
  description = "URL of the Databricks workspace"
  value       = "https://${azurerm_databricks_workspace.main.workspace_url}/"
}

output "databricks_workspace_name" {
  description = "Name of the Databricks workspace"
  value       = azurerm_databricks_workspace.main.name
}

output "unity_catalog_metastore_id" {
  description = "ID of the Unity Catalog metastore"
  value       = var.enable_unity_catalog ? databricks_metastore.unity_catalog.id : null
}

output "unity_catalog_storage_account_name" {
  description = "Name of the storage account used for Unity Catalog"
  value       = azurerm_storage_account.unity_catalog.name
}

output "unity_catalog_storage_account_id" {
  description = "ID of the storage account used for Unity Catalog"
  value       = azurerm_storage_account.unity_catalog.id
}

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

output "key_vault_uri" {
  description = "URI of the Key Vault"
  value       = azurerm_key_vault.main.vault_uri
}

output "managed_identity_id" {
  description = "ID of the managed identity"
  value       = azurerm_user_assigned_identity.databricks.id
}

output "managed_identity_principal_id" {
  description = "Principal ID of the managed identity"
  value       = azurerm_user_assigned_identity.databricks.principal_id
}

output "managed_identity_client_id" {
  description = "Client ID of the managed identity"
  value       = azurerm_user_assigned_identity.databricks.client_id
}

output "virtual_network_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = azurerm_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = azurerm_subnet.private.id
}

output "unity_catalog_cluster_id" {
  description = "ID of the Unity Catalog cluster"
  value       = databricks_cluster.unity_catalog_cluster.id
}

output "shared_cluster_id" {
  description = "ID of the shared cluster"
  value       = databricks_cluster.shared_cluster.id
}

output "sql_warehouse_id" {
  description = "ID of the SQL warehouse"
  value       = databricks_sql_endpoint.analytics.id
}

output "access_connector_id" {
  description = "ID of the Databricks access connector"
  value       = var.enable_unity_catalog ? azurerm_databricks_access_connector.unity_catalog.id : null
}

output "main_catalog_name" {
  description = "Name of the main Unity Catalog catalog"
  value       = var.enable_unity_catalog ? databricks_catalog.main.name : null
}

output "deployment_summary" {
  description = "Summary of deployed resources"
  value = {
    environment           = var.environment
    location              = var.location
    resource_group        = azurerm_resource_group.main.name
    databricks_workspace  = azurerm_databricks_workspace.main.name
    workspace_url         = "https://${azurerm_databricks_workspace.main.workspace_url}/"
    unity_catalog_enabled = var.enable_unity_catalog
    metastore_id          = var.enable_unity_catalog ? databricks_metastore.unity_catalog.id : null
    cluster_count         = 2
    sql_warehouse         = databricks_sql_endpoint.analytics.name
  }
}
