# Pre-Deployment Checklist

Before deploying the Azure Databricks with Unity Catalog infrastructure, please ensure you have completed the following:

## ✅ Prerequisites Checklist

### 1. Software Requirements
- [ ] Azure CLI installed and updated to latest version
- [ ] Terraform >= 1.0 installed
- [ ] PowerShell 5.1+ or Bash shell available
- [ ] jq installed (for JSON parsing in outputs)

### 2. Azure Access Requirements
- [ ] Azure subscription access with appropriate permissions
- [ ] Ability to create resource groups and resources
- [ ] Owner or Contributor role on the subscription (for role assignments)
- [ ] Logged in to Azure CLI (`az login` completed)

### 3. Databricks Account Setup
- [ ] Databricks account created at https://accounts.azuredatabricks.net/
- [ ] Databricks Account ID obtained from account console
- [ ] Account admin permissions (for Unity Catalog setup)

### 4. Configuration
- [ ] Review and customize `terraform.tfvars` with your settings
- [ ] Set unity_catalog_admin_users with actual email addresses
- [ ] Configure allowed_ip_ranges if network restrictions needed
- [ ] Set TF_VAR_databricks_account_id environment variable

### 5. Network Planning
- [ ] Verify VNet address space (10.0.0.0/16) doesn't conflict with existing networks
- [ ] Plan subnet allocation (public: 10.0.1.0/24, private: 10.0.2.0/24)
- [ ] Review NSG rules and security requirements

## 🚀 Deployment Steps

### Quick Deployment (Recommended)
```powershell
# 1. Navigate to infrastructure directory
cd infra

# 2. Set your Databricks Account ID
$env:TF_VAR_databricks_account_id = "your-account-id-here"

# 3. Run deployment script
.\deploy.ps1 deploy
```

### Manual Deployment
```powershell
# 1. Initialize Terraform
terraform init

# 2. Plan deployment
terraform plan -var-file="terraform.tfvars"

# 3. Apply deployment
terraform apply -var-file="terraform.tfvars"
```

## 📋 Post-Deployment Validation

### 1. Azure Resources
- [ ] Resource group created with all expected resources
- [ ] Databricks workspace accessible
- [ ] Storage account and container for Unity Catalog created
- [ ] Key Vault and managed identity configured
- [ ] Virtual network and subnets properly configured

### 2. Databricks Workspace
- [ ] Workspace URL accessible via browser
- [ ] Unity Catalog enabled and visible in workspace
- [ ] Clusters can be started successfully
- [ ] SQL warehouse is available and running

### 3. Unity Catalog
- [ ] Metastore appears in Unity Catalog explorer
- [ ] Main catalog and default schema created
- [ ] Admin users have appropriate permissions
- [ ] Storage access working correctly

## 🔍 Troubleshooting Common Issues

### Unity Catalog Issues
- **Metastore not visible**: Verify Databricks Account ID is correct
- **Storage access denied**: Check access connector permissions
- **Catalog creation fails**: Ensure proper role assignments

### Network Issues
- **Cluster start fails**: Check subnet delegation and NSG rules
- **Connection timeouts**: Verify no IP restrictions blocking access
- **VNet integration issues**: Confirm no address space conflicts

### Permission Issues
- **Terraform apply fails**: Verify Azure subscription permissions
- **Role assignment errors**: Ensure Owner/Contributor access
- **Key Vault access denied**: Check managed identity configuration

## 📞 Getting Help

If you encounter issues:
1. Check the detailed README.md in the infra/ directory
2. Review Terraform error messages carefully
3. Verify all prerequisites are met
4. Check Azure portal for resource creation status
5. Review Databricks workspace logs

## 🔄 Environment Management

### Development Environment
- Uses `terraform.tfvars`
- Smaller VM sizes for cost optimization
- Public IP allowed for easier access

### Production Environment  
- Uses `prod.tfvars`
- Larger VM sizes for performance
- No public IP for enhanced security
- Stricter network controls

### Switching Environments
```powershell
# Deploy to production
.\deploy.ps1 deploy prod.tfvars

# Plan production changes
.\deploy.ps1 plan prod.tfvars
```

---

**Important**: Always review the Terraform plan output before applying changes, especially in production environments.
