# Terraform version and state configuration
terraform {
  # Uncomment and configure the backend for remote state storage
  # backend "azurerm" {
  #   resource_group_name  = "rg-terraform-state"
  #   storage_account_name = "terraformstatestorageacc"
  #   container_name       = "tfstate"
  #   key                  = "databricks/terraform.tfstate"
  # }

  required_version = ">= 1.0"
}
