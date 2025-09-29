# Sample Deployment Commands

# This file shows the typical deployment workflow
# Make sure to install prerequisites first:
# 1. Azure CLI: https://docs.microsoft.com/en-us/cli/azure/install-azure-cli
# 2. Terraform: https://learn.hashicorp.com/tutorials/terraform/install-cli

# Step 1: Login to Azure
az login

# Step 2: Set your subscription
az account set --subscription "your-subscription-id"

# Step 3: Set environment variables
# Replace with your actual Databricks Account ID
$env:TF_VAR_databricks_account_id = "your-databricks-account-id"

# Step 4: Initialize Terraform
terraform init

# Step 5: Validate configuration
terraform validate

# Step 6: Format code
terraform fmt

# Step 7: Plan deployment (development)
terraform plan -var-file="terraform.tfvars"

# Step 8: Apply deployment
terraform apply -var-file="terraform.tfvars"

# For production deployment:
# terraform plan -var-file="prod.tfvars"
# terraform apply -var-file="prod.tfvars"

# To see outputs:
terraform output

# To destroy (be careful!):
# terraform destroy -var-file="terraform.tfvars"
