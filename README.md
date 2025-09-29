# Azure Databricks Business Continuity and Disaster Recovery (BCDR)

This repository contains Infrastructure as Code (IaC) solutions for deploying Azure Databricks with Unity Catalog and comprehensive business continuity and disaster recovery capabilities.

## 🏗️ Architecture Overview

The solution provides:
- **Azure Databricks Workspace** with Premium SKU and Unity Catalog
- **Complete Unity Catalog setup** with dedicated metastore and storage
- **Security-first design** with VNet integration and managed identities
- **Multi-environment support** (dev, staging, production)
- **Monitoring and governance** capabilities

## 📁 Repository Structure

```
├── infra/                 # Terraform Infrastructure as Code
│   ├── main.tf           # Core Azure resources
│   ├── unity-catalog.tf  # Unity Catalog configuration
│   ├── clusters.tf       # Databricks clusters
│   ├── security.tf       # Security and monitoring
│   ├── variables.tf      # Variable definitions
│   ├── outputs.tf        # Output values
│   ├── deploy.ps1        # PowerShell deployment script
│   ├── deploy.sh         # Bash deployment script
│   └── README.md         # Detailed infrastructure documentation
├── src/                  # Source code and notebooks
└── LICENSE

```

## 🚀 Quick Start

### Prerequisites
- Azure CLI installed and configured
- Terraform >= 1.0
- Databricks Account ID (get from https://accounts.azuredatabricks.net/)

### Deployment
1. **Clone and navigate to infrastructure:**
   ```bash
   cd infra
   ```

2. **Configure your environment:**
   ```bash
   # Copy and customize the variables file
   cp terraform.tfvars terraform.tfvars.local
   # Edit terraform.tfvars.local with your settings
   ```

3. **Set your Databricks Account ID:**
   ```bash
   export TF_VAR_databricks_account_id="your-account-id-here"
   ```

4. **Deploy using the automated script:**
   ```bash
   # On Linux/Mac
   chmod +x deploy.sh
   ./deploy.sh deploy

   # On Windows
   .\deploy.ps1 deploy
   ```

## 🔧 Key Features

### Unity Catalog Integration
- Automated metastore creation and configuration
- Cross-workspace catalog sharing
- Secure storage access with managed identities
- Pre-configured catalogs and schemas

### Security & Compliance
- VNet injection with custom subnets
- Network Security Groups with minimal access
- Azure Key Vault integration
- Diagnostic logging and monitoring
- IP-based access restrictions

### High Availability
- Multi-zone deployment support
- Autoscaling cluster configuration
- Separate clusters for different workloads
- SQL warehouse for analytics

### DevOps Ready
- Multi-environment configuration
- Terraform best practices
- Automated deployment scripts
- Comprehensive documentation

## 📖 Documentation

- [Infrastructure Documentation](./infra/README.md) - Detailed Terraform documentation
- [Deployment Guide](./infra/README.md#getting-started) - Step-by-step deployment instructions
- [Security Configuration](./infra/README.md#security-best-practices) - Security best practices

## 🤝 Contributing

1. Fork the repository
2. Create a feature branch
3. Make your changes
4. Test thoroughly
5. Submit a pull request

## 📄 License

This project is licensed under the MIT License - see the [LICENSE](LICENSE) file for details.

## 🆘 Support

For issues and questions:
- Check the [troubleshooting guide](./infra/README.md#troubleshooting)
- Review the infrastructure documentation
- Create an issue in this repository

---

**Note**: This solution is designed for enterprise-grade deployments with security, compliance, and governance in mind. Please review all configurations before deploying to production environments.