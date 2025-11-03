# Lab 1: Environment Setup & Prerequisites

**Estimated Time**: 45-60 minutes  
**Difficulty**: Beginner  
**Prerequisites**: Azure subscription access

## 🎯 **Lab Objectives**

In this lab, you will:
- Set up your development environment
- Install and configure required tools
- Authenticate with Azure
- Prepare your workspace for Terraform development

## 📋 **Prerequisites Checklist**

### **Azure Requirements**
- [ ] Active Azure subscription
- [ ] Contributor or Owner permissions on subscription
- [ ] Access to create resource groups and resources

### **Development Environment**
- [ ] Windows 10/11, macOS, or Linux
- [ ] Internet connection
- [ ] Administrative access to install software

## 🛠️ **Step 1: Install Required Tools**

### **1.1 Install Azure CLI**

**Windows (PowerShell as Administrator):**
```powershell
# Download and install Azure CLI
Invoke-WebRequest -Uri https://aka.ms/installazurecliwindows -OutFile .\AzureCLI.msi
Start-Process msiexec.exe -Wait -ArgumentList '/I AzureCLI.msi /quiet'
```

**macOS:**
```bash
brew install azure-cli
```

**Linux (Ubuntu/Debian):**
```bash
curl -sL https://aka.ms/InstallAzureCLIDeb | sudo bash
```

**Verify Installation:**
```bash
az version
```

### **1.2 Install Terraform**

**Windows (using Chocolatey):**
```powershell
# Install Chocolatey if not installed
Set-ExecutionPolicy Bypass -Scope Process -Force; [System.Net.ServicePointManager]::SecurityProtocol = [System.Net.ServicePointManager]::SecurityProtocol -bor 3072; iex ((New-Object System.Net.WebClient).DownloadString('https://community.chocolatey.org/install.ps1'))

# Install Terraform
choco install terraform
```

**Windows (Manual):**
1. Download from https://www.terraform.io/downloads.html
2. Extract to a directory (e.g., `C:\terraform`)
3. Add to PATH environment variable

**macOS:**
```bash
brew install terraform
```

**Linux:**
```bash
wget https://releases.hashicorp.com/terraform/1.5.0/terraform_1.5.0_linux_amd64.zip
unzip terraform_1.5.0_linux_amd64.zip
sudo mv terraform /usr/local/bin/
```

**Verify Installation:**
```bash
terraform version
```

### **1.3 Install Git (if not already installed)**

**Windows:**
```powershell
choco install git
```

**macOS:**
```bash
brew install git
```

**Linux:**
```bash
sudo apt install git
```

### **1.4 Install Visual Studio Code (Recommended)**

**Windows:**
```powershell
choco install vscode
```

**Or download from**: https://code.visualstudio.com/

**Recommended VS Code Extensions:**
- Azure Terraform
- HashiCorp Terraform
- Azure Account
- PowerShell (for Windows users)

## 🔐 **Step 2: Azure Authentication Setup**

### **2.1 Login to Azure**

```bash
az login
```

This will open a browser window for authentication.

### **2.2 List Available Subscriptions**

```bash
az account list --output table
```

### **2.3 Set Default Subscription**

```bash
az account set --subscription "Your-Subscription-Name-or-ID"
```

### **2.4 Verify Current Account**

```bash
az account show
```

## 📁 **Step 3: Workspace Preparation**

### **3.1 Create Lab Directory**

```bash
# Create and navigate to lab directory
mkdir ~/azure-databricks-lab
cd ~/azure-databricks-lab

# Initialize Git repository
git init
```

### **3.2 Clone Lab Repository (if available)**

```bash
git clone <your-lab-repository-url>
cd adb-bcdr/labs/lab-01-setup
```

### **3.3 Test Terraform Azure Provider**

Create a test file to verify everything works:

```bash
# Create test directory
mkdir terraform-test
cd terraform-test
```

Create `test.tf`:
```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
  }
}

provider "azurerm" {
  features {}
}

data "azurerm_client_config" "current" {}

output "current_user" {
  value = data.azurerm_client_config.current
}
```

Test the configuration:
```bash
terraform init
terraform plan
```

If successful, clean up:
```bash
cd ..
rm -rf terraform-test
```

## 🎯 **Step 4: Validation Exercises**

### **Exercise 1: Environment Verification**

Run these commands and verify they work without errors:

```bash
# Check Azure CLI
az account show --output table

# Check Terraform
terraform version

# Check Git
git --version
```

### **Exercise 2: Azure Resource Group Test**

Create a test resource group to verify permissions:

```bash
# Create test resource group
az group create --name "rg-lab-test" --location "East US"

# List resource groups
az group list --output table

# Delete test resource group
az group delete --name "rg-lab-test" --yes --no-wait
```

## ✅ **Lab 1 Completion Checklist**

- [ ] Azure CLI installed and working
- [ ] Terraform installed and working
- [ ] Successfully authenticated with Azure
- [ ] Can create and delete Azure resources
- [ ] Development environment set up
- [ ] VS Code installed with recommended extensions

## 🔄 **Troubleshooting**

### **Common Issues**

**Azure CLI Login Issues:**
- Ensure you're using the correct tenant
- Try `az login --tenant <tenant-id>`
- Clear cache: `az account clear`

**Terraform Provider Issues:**
- Run `terraform init -upgrade`
- Check Azure CLI authentication: `az account show`

**Permission Issues:**
- Verify you have Contributor/Owner role
- Check subscription access in Azure Portal

## 🚀 **Next Steps**

Congratulations! You've completed Lab 1. You're now ready to proceed to:

**Lab 2: Basic Azure Resources**
- Create VNet and subnets
- Set up storage accounts
- Configure Key Vault

---

**Estimated completion time**: If you completed this in 45-60 minutes, you're ready for the next lab!