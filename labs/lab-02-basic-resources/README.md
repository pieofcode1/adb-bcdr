# Lab 2: Basic Azure Resources

**Estimated Time**: 60-75 minutes  
**Difficulty**: Beginner-Intermediate  
**Prerequisites**: Completed Lab 1

## 🎯 **Lab Objectives**

In this lab, you will:
- Create basic Azure infrastructure using Terraform
- Set up Virtual Network and subnets for Databricks
- Configure Storage Account for Unity Catalog
- Create Key Vault for secrets management
- Understand resource dependencies and naming conventions

## 📋 **Lab Components**

You will create:
- Resource Group
- Virtual Network with public/private subnets
- Network Security Groups
- Storage Account (ADLS Gen2)
- Key Vault
- Managed Identity

## 🏗️ **Step 1: Project Structure Setup**

### **1.1 Create Lab Directory**

```bash
cd ~/azure-databricks-lab
mkdir lab-02-basic-resources
cd lab-02-basic-resources
```

### **1.2 Create Initial Files**

```bash
touch main.tf
touch variables.tf
touch outputs.tf
touch terraform.tfvars
```

## 📝 **Step 2: Define Variables**

Create `variables.tf`:

```hcl
variable "environment" {
  description = "Environment name (e.g., dev, staging, prod)"
  type        = string
  default     = "lab"
}

variable "location" {
  description = "Azure region where resources will be created"
  type        = string
  default     = "East US"
}

variable "resource_prefix" {
  description = "Prefix for resource names"
  type        = string
  default     = "databricks"
}
```

## 🏭 **Step 3: Create Main Infrastructure**

### **3.1 Provider and Random String**

Add to `main.tf`:

```hcl
terraform {
  required_providers {
    azurerm = {
      source  = "hashicorp/azurerm"
      version = "~>3.0"
    }
    random = {
      source  = "hashicorp/random"
      version = "~>3.1"
    }
  }
  required_version = ">= 1.0"
}

provider "azurerm" {
  features {
    key_vault {
      purge_soft_delete_on_destroy    = true
      recover_soft_deleted_key_vaults = true
    }
  }
}

# Generate random suffix for unique naming
resource "random_string" "suffix" {
  length  = 6
  special = false
  upper   = false
}

# Local values for consistent tagging
locals {
  common_tags = {
    Environment = var.environment
    Project     = "Azure Databricks Lab"
    ManagedBy   = "Terraform"
    Lab         = "Lab-02"
  }
}
```

### **3.2 Resource Group**

Add to `main.tf`:

```hcl
# Create Resource Group
resource "azurerm_resource_group" "main" {
  name     = "rg-${var.resource_prefix}-${var.environment}-${random_string.suffix.result}"
  location = var.location

  tags = local.common_tags
}
```

### **3.3 Virtual Network and Subnets**

Add to `main.tf`:

```hcl
# Create Virtual Network
resource "azurerm_virtual_network" "main" {
  name                = "vnet-${var.resource_prefix}-${var.environment}-${random_string.suffix.result}"
  address_space       = ["10.0.0.0/16"]
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = local.common_tags
}

# Create Public Subnet (for Databricks)
resource "azurerm_subnet" "public" {
  name                 = "snet-databricks-public"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.1.0/24"]

  # Delegation for Databricks (will be used in Lab 3)
  delegation {
    name = "databricks-delegation-public"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
      ]
    }
  }
}

# Create Private Subnet (for Databricks)
resource "azurerm_subnet" "private" {
  name                 = "snet-databricks-private"
  resource_group_name  = azurerm_resource_group.main.name
  virtual_network_name = azurerm_virtual_network.main.name
  address_prefixes     = ["10.0.2.0/24"]

  delegation {
    name = "databricks-delegation-private"
    service_delegation {
      name = "Microsoft.Databricks/workspaces"
      actions = [
        "Microsoft.Network/virtualNetworks/subnets/join/action",
        "Microsoft.Network/virtualNetworks/subnets/prepareNetworkPolicies/action",
        "Microsoft.Network/virtualNetworks/subnets/unprepareNetworkPolicies/action"
      ]
    }
  }
}
```

## 🔐 **Step 4: Security Resources**

### **4.1 Network Security Groups**

Add to `main.tf`:

```hcl
# Network Security Group for Public Subnet
resource "azurerm_network_security_group" "public" {
  name                = "nsg-databricks-public-${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = local.common_tags
}

# Network Security Group for Private Subnet
resource "azurerm_network_security_group" "private" {
  name                = "nsg-databricks-private-${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = local.common_tags
}

# Associate NSG with Public Subnet
resource "azurerm_subnet_network_security_group_association" "public" {
  subnet_id                 = azurerm_subnet.public.id
  network_security_group_id = azurerm_network_security_group.public.id
}

# Associate NSG with Private Subnet
resource "azurerm_subnet_network_security_group_association" "private" {
  subnet_id                 = azurerm_subnet.private.id
  network_security_group_id = azurerm_network_security_group.private.id
}
```

### **4.2 Storage Account for Unity Catalog**

Add to `main.tf`:

```hcl
# Storage Account for Unity Catalog Metastore
resource "azurerm_storage_account" "unity_catalog" {
  name                     = "st${replace(var.environment, "-", "")}uc${random_string.suffix.result}"
  resource_group_name      = azurerm_resource_group.main.name
  location                 = azurerm_resource_group.main.location
  account_tier             = "Standard"
  account_replication_type = "LRS"
  account_kind             = "StorageV2"
  is_hns_enabled           = true # Enable hierarchical namespace for Data Lake Gen2

  tags = local.common_tags
}

# Storage Container for Unity Catalog
resource "azurerm_storage_container" "unity_catalog" {
  name                  = "unity-catalog"
  storage_account_name  = azurerm_storage_account.unity_catalog.name
  container_access_type = "private"
}
```

### **4.3 Key Vault**

Add to `main.tf`:

```hcl
# Get current client configuration
data "azurerm_client_config" "current" {}

# Key Vault for secrets management
resource "azurerm_key_vault" "main" {
  name                = "kv-databricks-${var.environment}-${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name
  tenant_id           = data.azurerm_client_config.current.tenant_id
  sku_name            = "standard"

  enable_rbac_authorization = true
  purge_protection_enabled  = false # Set to true for production

  tags = local.common_tags
}

# Managed Identity for Databricks
resource "azurerm_user_assigned_identity" "databricks" {
  name                = "mi-databricks-${var.environment}-${random_string.suffix.result}"
  location            = azurerm_resource_group.main.location
  resource_group_name = azurerm_resource_group.main.name

  tags = local.common_tags
}
```

## 📤 **Step 5: Define Outputs**

Create `outputs.tf`:

```hcl
output "resource_group_name" {
  description = "Name of the resource group"
  value       = azurerm_resource_group.main.name
}

output "virtual_network_id" {
  description = "ID of the virtual network"
  value       = azurerm_virtual_network.main.id
}

output "public_subnet_id" {
  description = "ID of the public subnet"
  value       = azurerm_subnet.public.id
}

output "private_subnet_id" {
  description = "ID of the private subnet"
  value       = azurerm_subnet.private.id
}

output "storage_account_name" {
  description = "Name of the Unity Catalog storage account"
  value       = azurerm_storage_account.unity_catalog.name
}

output "key_vault_id" {
  description = "ID of the Key Vault"
  value       = azurerm_key_vault.main.id
}

output "managed_identity_id" {
  description = "ID of the managed identity"
  value       = azurerm_user_assigned_identity.databricks.id
}
```

## ⚙️ **Step 6: Configure Variables**

Create `terraform.tfvars`:

```hcl
environment     = "lab02"
location        = "East US"
resource_prefix = "databricks"
```

## 🚀 **Step 7: Deploy Infrastructure**

### **7.1 Initialize Terraform**

```bash
terraform init
```

### **7.2 Validate Configuration**

```bash
terraform validate
```

### **7.3 Plan Deployment**

```bash
terraform plan
```

### **7.4 Apply Configuration**

```bash
terraform apply
```

Type `yes` when prompted.

## 🧪 **Step 8: Validation Exercises**

### **Exercise 1: Verify Resources in Azure Portal**

1. Login to Azure Portal (https://portal.azure.com)
2. Navigate to your resource group
3. Verify all resources are created:
   - Virtual Network with 2 subnets
   - Storage Account with container
   - Key Vault
   - Managed Identity
   - Network Security Groups

### **Exercise 2: Test Resource Connections**

```bash
# List all resources in the resource group
az resource list --resource-group $(terraform output -raw resource_group_name) --output table

# Check storage account details
az storage account show --name $(terraform output -raw storage_account_name) --resource-group $(terraform output -raw resource_group_name)
```

### **Exercise 3: Review Terraform State**

```bash
# Show current state
terraform show

# List resources in state
terraform state list
```

## 🎯 **Lab Challenges (Optional)**

### **Challenge 1: Add a Storage Account Access Policy**

Add a role assignment to give the managed identity access to the storage account.

### **Challenge 2: Create Additional Subnets**

Add a subnet for application gateways or other services.

### **Challenge 3: Implement Resource Locks**

Add resource locks to prevent accidental deletion.

## ✅ **Lab 2 Completion Checklist**

- [ ] All Terraform files created successfully
- [ ] Infrastructure deployed without errors
- [ ] All resources visible in Azure Portal
- [ ] Storage account has Data Lake Gen2 enabled
- [ ] Key Vault created with RBAC enabled
- [ ] Network security groups associated with subnets
- [ ] Outputs display correct resource information

## 🧹 **Cleanup (Optional)**

If you want to clean up resources:

```bash
terraform destroy
```

## 🔄 **Troubleshooting**

### **Common Issues**

**Storage Account Name Conflicts:**
- Storage account names must be globally unique
- The random suffix should prevent this

**Permission Issues:**
- Ensure you have Contributor role on subscription
- Check if tenant has specific policies

**Terraform State Issues:**
- Delete `.terraform` directory and run `terraform init` again

## 🚀 **Next Steps**

Congratulations! You've successfully created the foundational Azure resources. You're now ready for:

**Lab 3: Azure Databricks Workspace Creation**
- Deploy Databricks workspace
- Configure VNet injection
- Set up initial clusters

---

**Key Learnings**: You now understand how to create Azure networking, storage, and security resources that form the foundation for a secure Databricks deployment.