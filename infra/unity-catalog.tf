# Unity Catalog Configuration
# This file configures Unity Catalog metastore and related resources

# Configure Databricks provider for account-level operations
provider "databricks" {
  alias      = "accounts"
  host       = "https://accounts.azuredatabricks.net"
  account_id = var.databricks_account_id
}

# Configure Databricks provider for workspace-level operations
provider "databricks" {
  alias = "workspace"
  host  = azurerm_databricks_workspace.main.workspace_url
}

# Create Unity Catalog Metastore (Account-level resource)
resource "databricks_metastore" "unity_catalog" {
  provider      = databricks.accounts
  name          = "metastore-${var.environment}-${random_string.suffix.result}"
  storage_root  = "abfss://${azurerm_storage_container.unity_catalog.name}@${azurerm_storage_account.unity_catalog.name}.dfs.core.windows.net/"
  region        = var.metastore_region
  force_destroy = true

  depends_on = [
    azurerm_role_assignment.unity_catalog_storage_blob_data_contributor
  ]
}

# Create Unity Catalog Metastore Data Access Configuration
resource "databricks_metastore_data_access" "unity_catalog" {
  provider     = databricks.accounts
  metastore_id = databricks_metastore.unity_catalog.id
  name         = "unity-catalog-access-${random_string.suffix.result}"
  azure_managed_identity {
    access_connector_id = azurerm_databricks_access_connector.unity_catalog.id
  }
  is_default = true
}

# Assign Unity Catalog Metastore to Workspace
resource "databricks_metastore_assignment" "workspace" {
  provider     = databricks.accounts
  workspace_id = azurerm_databricks_workspace.main.workspace_id
  metastore_id = databricks_metastore.unity_catalog.id
}

# Set default catalog using the recommended resource
resource "databricks_default_namespace_setting" "default_catalog" {
  provider = databricks.workspace
  namespace {
    value = "main"
  }
  depends_on = [databricks_metastore_assignment.workspace, databricks_catalog.main]
}

# Create Databricks Access Connector for Unity Catalog
resource "azurerm_databricks_access_connector" "unity_catalog" {
  name                = "dac-unity-catalog-${var.environment}-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location

  identity {
    type = "SystemAssigned"
  }

  tags = local.common_tags
}

# Role assignment for Unity Catalog access to storage
resource "azurerm_role_assignment" "unity_catalog_storage_blob_data_contributor" {
  scope                = azurerm_storage_account.unity_catalog.id
  role_definition_name = "Storage Blob Data Contributor"
  principal_id         = azurerm_databricks_access_connector.unity_catalog.identity[0].principal_id
}

# Create default catalog in Unity Catalog
resource "databricks_catalog" "main" {
  provider      = databricks.workspace
  name          = "main"
  comment       = "Main catalog for ${var.environment} environment"
  force_destroy = true

  depends_on = [
    databricks_metastore_assignment.workspace
  ]
}

# Create default schema in the main catalog
resource "databricks_schema" "default" {
  provider      = databricks.workspace
  catalog_name  = databricks_catalog.main.name
  name          = "default"
  comment       = "Default schema for ${var.environment} environment"
  force_destroy = true
}

# Grant Unity Catalog admin permissions to specified users
resource "databricks_grant" "metastore_admin" {
  provider   = databricks.workspace
  count      = length(var.unity_catalog_admin_users)
  metastore  = databricks_metastore.unity_catalog.id
  principal  = var.unity_catalog_admin_users[count.index]
  privileges = ["CREATE_CATALOG", "CREATE_CONNECTION", "CREATE_EXTERNAL_LOCATION"]

  depends_on = [
    databricks_metastore_assignment.workspace
  ]
}

# Grant catalog usage permissions to admin users
resource "databricks_grant" "catalog_usage" {
  provider   = databricks.workspace
  count      = length(var.unity_catalog_admin_users)
  catalog    = databricks_catalog.main.name
  principal  = var.unity_catalog_admin_users[count.index]
  privileges = ["USE_CATALOG", "USE_SCHEMA", "CREATE_SCHEMA"]
}
