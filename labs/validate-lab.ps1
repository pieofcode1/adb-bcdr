#!/usr/bin/env powershell
# Lab Validation Script - Validates lab completion and resource deployment

param(
    [Parameter(Mandatory=$true)]
    [ValidateSet("lab-01", "lab-02", "lab-03", "lab-04", "lab-05", "lab-06", "lab-07", "lab-08", "lab-09", "lab-10", "lab-11", "lab-12")]
    [string]$LabNumber,
    
    [Parameter(Mandatory=$false)]
    [string]$ResourceGroupName = ""
)

# Colors for output
$Green = [System.ConsoleColor]::Green
$Red = [System.ConsoleColor]::Red
$Yellow = [System.ConsoleColor]::Yellow
$Blue = [System.ConsoleColor]::Blue

function Write-ColorOutput {
    param(
        [string]$Message,
        [System.ConsoleColor]$Color = [System.ConsoleColor]::White
    )
    Write-Host $Message -ForegroundColor $Color
}

function Test-Prerequisites {
    Write-ColorOutput "🔍 Checking Prerequisites..." $Blue
    
    # Check Azure CLI
    try {
        $azVersion = az version --output json | ConvertFrom-Json
        Write-ColorOutput "✅ Azure CLI: $($azVersion.'azure-cli')" $Green
    }
    catch {
        Write-ColorOutput "❌ Azure CLI not found or not working" $Red
        return $false
    }
    
    # Check Terraform
    try {
        $tfVersion = terraform version -json | ConvertFrom-Json
        Write-ColorOutput "✅ Terraform: $($tfVersion.terraform_version)" $Green
    }
    catch {
        Write-ColorOutput "❌ Terraform not found or not working" $Red
        return $false
    }
    
    # Check Azure Authentication
    try {
        $account = az account show --output json | ConvertFrom-Json
        Write-ColorOutput "✅ Azure Account: $($account.name)" $Green
    }
    catch {
        Write-ColorOutput "❌ Not authenticated with Azure. Run 'az login'" $Red
        return $false
    }
    
    return $true
}

function Test-Lab01 {
    Write-ColorOutput "🧪 Validating Lab 1: Environment Setup" $Blue
    
    if (-not (Test-Prerequisites)) {
        return $false
    }
    
    Write-ColorOutput "✅ Lab 1 validation passed!" $Green
    return $true
}

function Test-Lab02 {
    param([string]$ResourceGroupName)
    
    Write-ColorOutput "🧪 Validating Lab 2: Basic Azure Resources" $Blue
    
    if (-not (Test-Prerequisites)) {
        return $false
    }
    
    if ([string]::IsNullOrEmpty($ResourceGroupName)) {
        # Try to get from Terraform output
        try {
            $ResourceGroupName = terraform output -raw resource_group_name
        }
        catch {
            Write-ColorOutput "❌ Could not determine resource group name. Provide -ResourceGroupName parameter." $Red
            return $false
        }
    }
    
    # Check if resource group exists
    try {
        $rg = az group show --name $ResourceGroupName --output json | ConvertFrom-Json
        Write-ColorOutput "✅ Resource Group: $($rg.name)" $Green
    }
    catch {
        Write-ColorOutput "❌ Resource Group '$ResourceGroupName' not found" $Red
        return $false
    }
    
    # Check expected resources
    $expectedResources = @(
        "Microsoft.Network/virtualNetworks",
        "Microsoft.Network/networkSecurityGroups", 
        "Microsoft.Storage/storageAccounts",
        "Microsoft.KeyVault/vaults",
        "Microsoft.ManagedIdentity/userAssignedIdentities"
    )
    
    try {
        $resources = az resource list --resource-group $ResourceGroupName --output json | ConvertFrom-Json
        
        foreach ($expectedType in $expectedResources) {
            $found = $resources | Where-Object { $_.type -eq $expectedType }
            if ($found) {
                Write-ColorOutput "✅ Found $expectedType" $Green
            }
            else {
                Write-ColorOutput "❌ Missing $expectedType" $Red
                return $false
            }
        }
    }
    catch {
        Write-ColorOutput "❌ Error checking resources in resource group" $Red
        return $false
    }
    
    Write-ColorOutput "✅ Lab 2 validation passed!" $Green
    return $true
}

function Get-LabInstructions {
    param([string]$LabNumber)
    
    Write-ColorOutput "📚 Lab $LabNumber Instructions:" $Blue
    
    switch ($LabNumber) {
        "lab-01" {
            Write-ColorOutput "1. Install Azure CLI and Terraform" $Yellow
            Write-ColorOutput "2. Authenticate with Azure (az login)" $Yellow
            Write-ColorOutput "3. Verify tools work correctly" $Yellow
        }
        "lab-02" {
            Write-ColorOutput "1. Create basic Azure resources with Terraform" $Yellow
            Write-ColorOutput "2. Deploy VNet, storage, and Key Vault" $Yellow
            Write-ColorOutput "3. Verify all resources are created" $Yellow
        }
        default {
            Write-ColorOutput "Instructions for $LabNumber coming soon!" $Yellow
        }
    }
}

function Show-NextSteps {
    param([string]$LabNumber)
    
    Write-ColorOutput "🚀 Next Steps:" $Blue
    
    switch ($LabNumber) {
        "lab-01" {
            Write-ColorOutput "Proceed to Lab 2: Basic Azure Resources" $Green
        }
        "lab-02" {
            Write-ColorOutput "Proceed to Lab 3: Azure Databricks Workspace" $Green
        }
        default {
            Write-ColorOutput "Check the lab series README for next steps" $Green
        }
    }
}

# Main execution
Write-ColorOutput "🎯 Azure Databricks Lab Validation Tool" $Blue
Write-ColorOutput "Lab: $LabNumber" $Blue
Write-ColorOutput "----------------------------------------" $Blue

$validationPassed = $false

switch ($LabNumber) {
    "lab-01" {
        $validationPassed = Test-Lab01
    }
    "lab-02" {
        $validationPassed = Test-Lab02 -ResourceGroupName $ResourceGroupName
    }
    default {
        Write-ColorOutput "❌ Validation for $LabNumber is not yet implemented" $Red
        Get-LabInstructions -LabNumber $LabNumber
        exit 1
    }
}

if ($validationPassed) {
    Write-ColorOutput "🎉 Congratulations! Lab $LabNumber completed successfully!" $Green
    Show-NextSteps -LabNumber $LabNumber
}
else {
    Write-ColorOutput "❌ Lab $LabNumber validation failed. Please review the instructions." $Red
    Get-LabInstructions -LabNumber $LabNumber
    exit 1
}