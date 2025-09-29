# Azure Databricks with Unity Catalog - Terraform Infrastructure

This repository contains Terraform infrastructure as code for deploying Azure Databricks workspace with Unity Catalog support.

## Architecture Overview

The infrastructure includes:
- **Azure Databricks Workspace** with Premium SKU
- **Unity Catalog** with dedicated metastore and storage
- **Virtual Network** with dedicated subnets for Databricks
- **Storage Account** (ADLS Gen2) for Unity Catalog metastore
- **Key Vault** for secrets management
- **Access Connector** for Unity Catalog authentication
- **Managed Identity** for secure access
- **Databricks Clusters** (Unity Catalog enabled and Shared)
- **SQL Warehouse** for analytics
- **Security and monitoring** configurations

## Prerequisites

1. **Azure CLI** - [Install Azure CLI](https://docs.microsoft.com/en-us/cli/azure/install-azure-cli)
2. **Terraform** - [Install Terraform](https://learn.hashicorp.com/tutorials/terraform/install-cli)
3. **Azure Subscription** with appropriate permissions
4. **Databricks Account** - You'll need the Databricks Account ID for Unity Catalog

## Getting Started

### 1. Authentication

Login to Azure:
```bash
az login
```

Set your subscription:
```bash
az account set --subscription "your-subscription-id"
```

### 2. Get Databricks Account ID

1. Go to [Databricks Account Console](https://accounts.azuredatabricks.net/)
2. Copy your Account ID from the URL or account settings
3. This will be needed for Unity Catalog configuration

### 3. Configure Variables

1. Copy `terraform.tfvars` to create your environment-specific configuration
2. Update the variables with your specific values:

```hcl
# Basic configuration
environment = "dev"
location    = "East US"

# Unity Catalog admin users
unity_catalog_admin_users = [
  "admin@yourdomain.com",
  "data-engineer@yourdomain.com"
]

# Network security (optional)
allowed_ip_ranges = [
  "203.0.113.0/24"  # Your office network
]
```

3. Set your Databricks Account ID as an environment variable:
```bash
export TF_VAR_databricks_account_id="your-databricks-account-id"
```

Or add it to your `.tfvars` file:
```hcl
databricks_account_id = "your-databricks-account-id"
```

### 4. Deploy Infrastructure

Initialize Terraform:
```bash
cd infra
terraform init
```

Plan the deployment:
```bash
terraform plan -var-file="terraform.tfvars"
```

Apply the configuration:
```bash
terraform apply -var-file="terraform.tfvars"
```

## Environment-Specific Deployments

For different environments, use the appropriate variable files:

```bash
# Development
terraform apply -var-file="terraform.tfvars"

# Production
terraform apply -var-file="prod.tfvars"
```

## Key Features

### Security
- Network isolation with dedicated VNet and subnets
- Network Security Groups with appropriate rules
- Managed Identity for secure authentication
- Key Vault integration for secrets management
- IP-based access restrictions (configurable)

### Unity Catalog
- Dedicated metastore with ADLS Gen2 storage
- Automatic catalog and schema creation
- Access connector for secure storage access
- Admin user permissions configuration
- Cross-workspace catalog sharing support

### Monitoring
- Log Analytics workspace integration
- Diagnostic settings for audit logging
- Resource tagging for cost management

### High Availability
- Multi-zone cluster deployment
- Autoscaling cluster configuration
- Separate clusters for different workloads

## Outputs

After successful deployment, Terraform will output:
- Databricks workspace URL
- Unity Catalog metastore ID
- Resource group information
- Storage account details
- Cluster IDs

## Post-Deployment Steps

1. **Access Databricks Workspace**:
   - Use the workspace URL from Terraform outputs
   - Login with your Azure AD credentials

2. **Verify Unity Catalog**:
   - Check that Unity Catalog is enabled
   - Verify the metastore connection
   - Test catalog and schema creation

3. **Configure User Access**:
   - Add users to appropriate workspace groups
   - Configure Unity Catalog permissions
   - Set up data access policies

4. **Test Clusters**:
   - Start the Unity Catalog cluster
   - Verify Unity Catalog functionality
   - Test data access and permissions

## File Structure

```
infra/
├── main.tf              # Main infrastructure resources
├── variables.tf         # Variable definitions
├── outputs.tf          # Output definitions
├── versions.tf         # Terraform and provider versions
├── unity-catalog.tf    # Unity Catalog configuration
├── clusters.tf         # Databricks clusters
├── security.tf         # Security and monitoring
├── terraform.tfvars    # Development variables
└── prod.tfvars         # Production variables
```

## Troubleshooting

### Unity Catalog Issues
- Verify Databricks Account ID is correct
- Check that the storage account has proper permissions
- Ensure the access connector is properly configured

### Network Issues
- Verify subnet delegation is properly configured
- Check NSG rules are not blocking traffic
- Ensure no conflicts with existing VNet address spaces

### Permission Issues
- Verify Azure AD permissions for Terraform service principal
- Check Databricks workspace admin permissions
- Ensure proper role assignments are in place

## Cleanup

To destroy all resources:
```bash
terraform destroy -var-file="terraform.tfvars"
```

**Warning**: This will delete all resources including data. Make sure to backup any important data before destroying.

## Cost Optimization

- Use autotermination for clusters to avoid idle costs
- Choose appropriate VM sizes based on workload requirements
- Monitor usage through Azure Cost Management
- Consider using Spot instances for non-critical workloads

## Security Best Practices

- Enable private endpoints for storage accounts in production
- Use Azure Private Link for Databricks workspace access
- Implement network security groups with minimal required access
- Regularly rotate keys and secrets
- Enable audit logging and monitoring
- Use Azure Policy for governance and compliance

## Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## License

This project is licensed under the MIT License - see the LICENSE file for details.
