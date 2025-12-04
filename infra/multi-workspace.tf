# Multi-Workspace Configuration for Unity Catalog Demo
# This file creates a second workspace to demonstrate cross-workspace data sharing

# Create second workspace for Analytics/Data Science
resource "azurerm_databricks_workspace" "analytics" {
  name                = "databricks-analytics-${var.environment}-${random_string.suffix.result}"
  resource_group_name = azurerm_resource_group.main.name
  location            = azurerm_resource_group.main.location
  sku                 = var.databricks_sku

  custom_parameters {
    no_public_ip        = var.no_public_ip
    public_subnet_name  = azurerm_subnet.public.name
    private_subnet_name = azurerm_subnet.private.name
    virtual_network_id  = azurerm_virtual_network.main.id

    public_subnet_network_security_group_association_id  = azurerm_subnet_network_security_group_association.public.id
    private_subnet_network_security_group_association_id = azurerm_subnet_network_security_group_association.private.id
  }

  tags = merge(
    local.common_tags,
    {
      Purpose = "Analytics and Data Science"
    }
  )

  depends_on = [
    azurerm_subnet_network_security_group_association.public,
    azurerm_subnet_network_security_group_association.private
  ]
}

# Configure Databricks provider for analytics workspace
provider "databricks" {
  alias = "analytics"
  host  = azurerm_databricks_workspace.analytics.workspace_url
}

# Assign the same Unity Catalog Metastore to Analytics Workspace
resource "databricks_metastore_assignment" "analytics_workspace" {
  provider     = databricks.accounts
  workspace_id = azurerm_databricks_workspace.analytics.workspace_id
  metastore_id = databricks_metastore.unity_catalog.id

  depends_on = [
    databricks_metastore_assignment.workspace
  ]
}

# Create Analytics Cluster in second workspace
resource "databricks_cluster" "analytics_cluster" {
  provider                = databricks.analytics
  cluster_name            = "analytics-cluster-${var.environment}"
  spark_version           = var.cluster_spark_version
  node_type_id           = var.cluster_node_type
  driver_node_type_id    = var.cluster_node_type
  autotermination_minutes = 30
  enable_elastic_disk     = true
  data_security_mode     = "USER_ISOLATION"

  autoscale {
    min_workers = var.cluster_min_workers
    max_workers = var.cluster_max_workers
  }

  spark_conf = {
    "spark.databricks.delta.preview.enabled"              = "true"
    "spark.databricks.cluster.profile"                   = "serverless"
    "spark.databricks.repl.allowedLanguages"            = "python,sql,scala,r"
    "spark.databricks.unity_catalog.enabled"            = "true"
    "spark.serializer"                                   = "org.apache.spark.serializer.KryoSerializer"
    "spark.sql.adaptive.enabled"                        = "true"
    "spark.sql.adaptive.coalescePartitions.enabled"     = "true"
  }

  custom_tags = {
    "Environment" = var.environment
    "Project"     = "Azure Databricks BCDR"
    "ManagedBy"   = "Terraform"
    "Purpose"     = "Analytics Workspace Cluster"
  }

  depends_on = [
    databricks_metastore_assignment.analytics_workspace,
    databricks_catalog.main
  ]
}

# Create a catalog specifically for shared data
resource "databricks_catalog" "shared" {
  provider     = databricks.workspace
  name         = "shared_data"
  comment      = "Shared catalog accessible across all workspaces"
  force_destroy = true

  depends_on = [
    databricks_metastore_assignment.workspace
  ]
}

# Create schema for sample datasets
resource "databricks_schema" "samples" {
  provider     = databricks.workspace
  catalog_name = databricks_catalog.shared.name
  name         = "samples"
  comment      = "Sample datasets for demonstration"
  force_destroy = true
}

# Grant access to shared catalog for analytics workspace users
resource "databricks_grant" "shared_catalog_usage" {
  provider   = databricks.workspace
  catalog    = databricks_catalog.shared.name
  principal  = "account users"
  privileges = ["USE_CATALOG", "USE_SCHEMA"]
}

# Grant SELECT on shared schema for read access from analytics workspace
resource "databricks_grant" "shared_schema_select" {
  provider   = databricks.workspace
  schema     = "${databricks_catalog.shared.name}.${databricks_schema.samples.name}"
  principal  = "account users"
  privileges = ["SELECT"]
}