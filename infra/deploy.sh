#!/bin/bash

# Azure Databricks with Unity Catalog Deployment Script
# This script helps deploy the Terraform infrastructure

set -e

# Colors for output
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m' # No Color

# Function to print colored output
print_status() {
    echo -e "${BLUE}[INFO]${NC} $1"
}

print_success() {
    echo -e "${GREEN}[SUCCESS]${NC} $1"
}

print_warning() {
    echo -e "${YELLOW}[WARNING]${NC} $1"
}

print_error() {
    echo -e "${RED}[ERROR]${NC} $1"
}

# Check if required tools are installed
check_dependencies() {
    print_status "Checking dependencies..."
    
    if ! command -v az &> /dev/null; then
        print_error "Azure CLI is not installed. Please install it first."
        exit 1
    fi
    
    if ! command -v terraform &> /dev/null; then
        print_error "Terraform is not installed. Please install it first."
        exit 1
    fi
    
    print_success "All dependencies are installed."
}

# Check Azure login status
check_azure_login() {
    print_status "Checking Azure login status..."
    
    if ! az account show &> /dev/null; then
        print_error "You are not logged in to Azure. Please run 'az login' first."
        exit 1
    fi
    
    SUBSCRIPTION=$(az account show --query name -o tsv)
    print_success "Logged in to Azure. Current subscription: $SUBSCRIPTION"
}

# Get Databricks Account ID
get_databricks_account_id() {
    print_warning "You need to provide your Databricks Account ID for Unity Catalog."
    print_status "You can find your Account ID at: https://accounts.azuredatabricks.net/"
    
    if [[ -z "${TF_VAR_databricks_account_id}" ]]; then
        read -p "Enter your Databricks Account ID: " DATABRICKS_ACCOUNT_ID
        export TF_VAR_databricks_account_id=$DATABRICKS_ACCOUNT_ID
    else
        print_success "Using Databricks Account ID from environment variable."
    fi
}

# Initialize Terraform
init_terraform() {
    print_status "Initializing Terraform..."
    terraform init
    print_success "Terraform initialized successfully."
}

# Plan deployment
plan_deployment() {
    local env_file=${1:-"terraform.tfvars"}
    print_status "Planning deployment with $env_file..."
    
    if [[ ! -f "$env_file" ]]; then
        print_error "Environment file $env_file not found."
        exit 1
    fi
    
    terraform plan -var-file="$env_file" -out=tfplan
    print_success "Terraform plan completed. Review the plan above."
}

# Apply deployment
apply_deployment() {
    print_status "Applying Terraform configuration..."
    
    read -p "Do you want to proceed with the deployment? (yes/no): " CONFIRM
    if [[ $CONFIRM != "yes" ]]; then
        print_warning "Deployment cancelled."
        exit 0
    fi
    
    terraform apply tfplan
    print_success "Deployment completed successfully!"
}

# Show outputs
show_outputs() {
    print_status "Deployment outputs:"
    terraform output -json | jq .
}

# Destroy infrastructure
destroy_infrastructure() {
    local env_file=${1:-"terraform.tfvars"}
    print_warning "This will destroy all infrastructure resources!"
    
    read -p "Are you sure you want to destroy everything? Type 'destroy' to confirm: " CONFIRM
    if [[ $CONFIRM != "destroy" ]]; then
        print_warning "Destruction cancelled."
        exit 0
    fi
    
    print_status "Destroying infrastructure..."
    terraform destroy -var-file="$env_file"
    print_success "Infrastructure destroyed."
}

# Main function
main() {
    local action=${1:-"deploy"}
    local env_file=${2:-"terraform.tfvars"}
    
    print_status "Starting Azure Databricks deployment script..."
    
    check_dependencies
    check_azure_login
    
    case $action in
        "deploy")
            get_databricks_account_id
            init_terraform
            plan_deployment "$env_file"
            apply_deployment
            show_outputs
            ;;
        "plan")
            get_databricks_account_id
            init_terraform
            plan_deployment "$env_file"
            ;;
        "destroy")
            get_databricks_account_id
            destroy_infrastructure "$env_file"
            ;;
        "output")
            show_outputs
            ;;
        *)
            echo "Usage: $0 [deploy|plan|destroy|output] [env-file]"
            echo ""
            echo "Actions:"
            echo "  deploy   - Plan and apply Terraform configuration (default)"
            echo "  plan     - Only plan the deployment"
            echo "  destroy  - Destroy all infrastructure"
            echo "  output   - Show deployment outputs"
            echo ""
            echo "Environment files:"
            echo "  terraform.tfvars - Development environment (default)"
            echo "  prod.tfvars      - Production environment"
            exit 1
            ;;
    esac
}

# Run main function with all arguments
main "$@"
