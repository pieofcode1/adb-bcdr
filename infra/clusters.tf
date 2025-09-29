# Databricks Cluster Configuration
# This file creates a Databricks cluster with Unity Catalog support

# Create Databricks cluster
resource "databricks_cluster" "unity_catalog_cluster" {
  provider                = databricks.workspace
  cluster_name            = "unity-catalog-cluster-${var.environment}"
  spark_version           = var.cluster_spark_version
  node_type_id            = var.cluster_node_type
  driver_node_type_id     = var.cluster_node_type
  autotermination_minutes = 30
  enable_elastic_disk     = true
  data_security_mode      = "USER_ISOLATION" # Required for Unity Catalog

  autoscale {
    min_workers = var.cluster_min_workers
    max_workers = var.cluster_max_workers
  }

  spark_conf = {
    # Unity Catalog configuration
    "spark.databricks.delta.preview.enabled" = "true"
    "spark.databricks.cluster.profile"       = "serverless"
    "spark.databricks.repl.allowedLanguages" = "python,sql,scala,r"
    "spark.databricks.unity_catalog.enabled" = "true"

    # Performance optimizations
    "spark.serializer"                              = "org.apache.spark.serializer.KryoSerializer"
    "spark.sql.adaptive.enabled"                    = "true"
    "spark.sql.adaptive.coalescePartitions.enabled" = "true"
  }

  custom_tags = {
    "Environment" = var.environment
    "Project"     = "Azure Databricks BCDR"
    "ManagedBy"   = "Terraform"
    "Purpose"     = "Unity Catalog Cluster"
  }

  depends_on = [
    databricks_metastore_assignment.workspace,
    databricks_catalog.main
  ]
}

# Create a shared cluster for collaborative work
resource "databricks_cluster" "shared_cluster" {
  provider                = databricks.workspace
  cluster_name            = "shared-cluster-${var.environment}"
  spark_version           = var.cluster_spark_version
  node_type_id            = var.cluster_node_type
  driver_node_type_id     = var.cluster_node_type
  autotermination_minutes = 60
  enable_elastic_disk     = true
  data_security_mode      = "SHARED" # Shared mode for collaborative work

  autoscale {
    min_workers = var.cluster_min_workers
    max_workers = var.cluster_max_workers
  }

  spark_conf = {
    "spark.databricks.delta.preview.enabled"        = "true"
    "spark.databricks.cluster.profile"              = "serverless"
    "spark.databricks.repl.allowedLanguages"        = "python,sql,scala,r"
    "spark.databricks.unity_catalog.enabled"        = "true"
    "spark.serializer"                              = "org.apache.spark.serializer.KryoSerializer"
    "spark.sql.adaptive.enabled"                    = "true"
    "spark.sql.adaptive.coalescePartitions.enabled" = "true"
  }

  library {
    pypi {
      package = "pandas"
    }
  }

  library {
    pypi {
      package = "numpy"
    }
  }

  library {
    pypi {
      package = "scikit-learn"
    }
  }

  custom_tags = {
    "Environment" = var.environment
    "Project"     = "Azure Databricks BCDR"
    "ManagedBy"   = "Terraform"
    "Purpose"     = "Shared Cluster"
  }

  depends_on = [
    databricks_metastore_assignment.workspace,
    databricks_catalog.main
  ]
}

# Create a SQL warehouse for analytics
resource "databricks_sql_endpoint" "analytics" {
  provider     = databricks.workspace
  name         = "analytics-warehouse-${var.environment}"
  cluster_size = "X-Small"

  tags {
    custom_tags {
      key   = "Environment"
      value = var.environment
    }
    custom_tags {
      key   = "Project"
      value = "Azure Databricks BCDR"
    }
    custom_tags {
      key   = "ManagedBy"
      value = "Terraform"
    }
  }

  depends_on = [
    databricks_metastore_assignment.workspace
  ]
}
