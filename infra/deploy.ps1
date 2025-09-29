# Azure Databricks with Unity Catalog Deployment Script (PowerShell)
# This script helps deploy the Terraform infrastructure on Windows

param(
    [Parameter(Position=0)]
    [ValidateSet("deploy", "plan", "destroy", "output")]
    [string]$Action = "deploy",
    
    [Parameter(Position=1)]
    [string]$EnvFile = "terraform.tfvars"
)

# Function to write colored output
function Write-Status {
    param([string]$Message)
    Write-Host "[INFO] $Message" -ForegroundColor Blue
}

function Write-Success {
    param([string]$Message)
    Write-Host "[SUCCESS] $Message" -ForegroundColor Green
}

function Write-Warning {
    param([string]$Message)
    Write-Host "[WARNING] $Message" -ForegroundColor Yellow
}

function Write-Error {
    param([string]$Message)
    Write-Host "[ERROR] $Message" -ForegroundColor Red
}

# Check if required tools are installed
function Test-Dependencies {
    Write-Status "Checking dependencies..."
    
    try {
        $null = Get-Command az -ErrorAction Stop
    }
    catch {
        Write-Error "Azure CLI is not installed. Please install it first."
        exit 1
    }
    
    try {
        $null = Get-Command terraform -ErrorAction Stop
    }
    catch {
        Write-Error "Terraform is not installed. Please install it first."
        exit 1
    }
    
    Write-Success "All dependencies are installed."
}

# Check Azure login status
function Test-AzureLogin {
    Write-Status "Checking Azure login status..."
    
    try {
        $account = az account show 2>$null | ConvertFrom-Json
        if (!$account) {
            throw "Not logged in"
        }
        Write-Success "Logged in to Azure. Current subscription: $($account.name)"
    }
    catch {
        Write-Error "You are not logged in to Azure. Please run 'az login' first."
        exit 1
    }
}

# Get Databricks Account ID
function Get-DatabricksAccountId {
    Write-Warning "You need to provide your Databricks Account ID for Unity Catalog."
    Write-Status "You can find your Account ID at: https://accounts.azuredatabricks.net/"
    
    if (!$env:TF_VAR_databricks_account_id) {
        $databricksAccountId = Read-Host "Enter your Databricks Account ID"
        $env:TF_VAR_databricks_account_id = $databricksAccountId
    }
    else {
        Write-Success "Using Databricks Account ID from environment variable."
    }
}

# Initialize Terraform
function Initialize-Terraform {
    Write-Status "Initializing Terraform..."
    terraform init
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Terraform initialization failed."
        exit 1
    }
    Write-Success "Terraform initialized successfully."
}

# Plan deployment
function New-DeploymentPlan {
    param([string]$EnvFile)
    
    Write-Status "Planning deployment with $EnvFile..."
    
    if (!(Test-Path $EnvFile)) {
        Write-Error "Environment file $EnvFile not found."
        exit 1
    }
    
    terraform plan -var-file="$EnvFile" -out=tfplan
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Terraform plan failed."
        exit 1
    }
    Write-Success "Terraform plan completed. Review the plan above."
}

# Apply deployment
function Start-Deployment {
    Write-Status "Applying Terraform configuration..."
    
    $confirm = Read-Host "Do you want to proceed with the deployment? (yes/no)"
    if ($confirm -ne "yes") {
        Write-Warning "Deployment cancelled."
        exit 0
    }
    
    terraform apply tfplan
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Terraform apply failed."
        exit 1
    }
    Write-Success "Deployment completed successfully!"
}

# Show outputs
function Show-Outputs {
    Write-Status "Deployment outputs:"
    terraform output -json
}

# Destroy infrastructure
function Remove-Infrastructure {
    param([string]$EnvFile)
    
    Write-Warning "This will destroy all infrastructure resources!"
    
    $confirm = Read-Host "Are you sure you want to destroy everything? Type 'destroy' to confirm"
    if ($confirm -ne "destroy") {
        Write-Warning "Destruction cancelled."
        exit 0
    }
    
    Write-Status "Destroying infrastructure..."
    terraform destroy -var-file="$EnvFile"
    if ($LASTEXITCODE -ne 0) {
        Write-Error "Terraform destroy failed."
        exit 1
    }
    Write-Success "Infrastructure destroyed."
}

# Main execution
Write-Status "Starting Azure Databricks deployment script..."

Test-Dependencies
Test-AzureLogin

switch ($Action) {
    "deploy" {
        Get-DatabricksAccountId
        Initialize-Terraform
        New-DeploymentPlan $EnvFile
        Start-Deployment
        Show-Outputs
    }
    "plan" {
        Get-DatabricksAccountId
        Initialize-Terraform
        New-DeploymentPlan $EnvFile
    }
    "destroy" {
        Get-DatabricksAccountId
        Remove-Infrastructure $EnvFile
    }
    "output" {
        Show-Outputs
    }
    default {
        Write-Host @"
Usage: .\deploy.ps1 [Action] [EnvFile]

Actions:
  deploy   - Plan and apply Terraform configuration (default)
  plan     - Only plan the deployment
  destroy  - Destroy all infrastructure
  output   - Show deployment outputs

Environment files:
  terraform.tfvars - Development environment (default)
  prod.tfvars      - Production environment

Examples:
  .\deploy.ps1                           # Deploy with default settings
  .\deploy.ps1 plan                      # Plan deployment only
  .\deploy.ps1 deploy prod.tfvars        # Deploy production environment
  .\deploy.ps1 destroy terraform.tfvars  # Destroy dev environment
"@
    }
}
