# Variables for the Terraform configuration
variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "dev"

  validation {
    condition     = can(regex("^[a-z0-9-]{2,10}$", var.environment))
    error_message = "Environment must be 2-10 characters long and contain only lowercase letters, numbers, and hyphens."
  }
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "East US"
}

variable "databricks_sku" {
  description = "The SKU for the Databricks workspace"
  type        = string
  default     = "premium"

  validation {
    condition     = contains(["standard", "premium", "trial"], var.databricks_sku)
    error_message = "Databricks SKU must be one of: standard, premium, trial."
  }
}

variable "no_public_ip" {
  description = "Whether to disable public IP for Databricks clusters"
  type        = bool
  default     = false
}

variable "cluster_node_type" {
  description = "Node type for Databricks cluster"
  type        = string
  default     = "Standard_DS3_v2"
}

variable "cluster_min_workers" {
  description = "Minimum number of workers for the cluster"
  type        = number
  default     = 1
}

variable "cluster_max_workers" {
  description = "Maximum number of workers for the cluster"
  type        = number
  default     = 4
}

variable "cluster_spark_version" {
  description = "Spark version for the cluster"
  type        = string
  default     = "13.3.x-scala2.12" # Latest LTS version as of 2024
}

variable "unity_catalog_admin_users" {
  description = "List of users who will be Unity Catalog administrators"
  type        = list(string)
  default     = []
}

variable "allowed_ip_ranges" {
  description = "List of IP ranges allowed to access Databricks workspace"
  type        = list(string)
  default     = []
}

variable "enable_unity_catalog" {
  description = "Whether to enable Unity Catalog"
  type        = bool
  default     = true
}

variable "metastore_region" {
  description = "Region for Unity Catalog metastore (should match workspace region)"
  type        = string
  default     = "eastus"
}

variable "databricks_account_id" {
  description = "Databricks account ID (required for Unity Catalog). Get this from your Databricks account console."
  type        = string
  default     = ""
  sensitive   = true
}
