# Unity Catalog Multi-Workspace Demo Guide

This guide demonstrates the power of Unity Catalog with multiple workspaces and cross-workspace data sharing.

## 🏗️ **Architecture Overview**

```
┌─────────────────────────────────────────────────────────────┐
│                   Unity Catalog Metastore                    │
│              (Account-Level, Cross-Workspace)                 │
└──────────────────────┬──────────────────────┬────────────────┘
                       │                      │
           ┌───────────▼─────────┐  ┌────────▼────────────┐
           │  PRIMARY WORKSPACE  │  │ ANALYTICS WORKSPACE │
           │  (Data Engineering) │  │  (Data Science/ML)  │
           └─────────────────────┘  └─────────────────────┘
                       │                      │
                       │  Shared Catalogs     │
                       └──────────┬───────────┘
                                  │
                    ┌─────────────▼─────────────┐
                    │  shared_data.samples.*    │
                    │  - customers              │
                    │  - products               │
                    │  - transactions           │
                    └───────────────────────────┘
```

## 📊 **Deployment Resources**

### **Infrastructure Components**
1. **2 Databricks Workspaces**
   - Primary: `databricks-{env}-{suffix}` (Data Engineering)
   - Analytics: `databricks-analytics-{env}-{suffix}` (Data Science)

2. **Shared Unity Catalog Metastore**
   - Single metastore attached to both workspaces
   - Centralized governance and metadata

3. **Shared Storage**
   - ADLS Gen2 for Unity Catalog metastore
   - Managed with access connector

4. **Clusters**
   - Unity Catalog cluster (Primary workspace)
   - Shared cluster (Primary workspace)
   - Analytics cluster (Analytics workspace)
   - SQL Warehouse (for BI tools)

## 🚀 **Deployment Steps**

### **1. Deploy Infrastructure**

```powershell
cd infra

# Initialize Terraform
terraform init

# Review the plan (note: creates 2 workspaces)
terraform plan -var-file="terraform.tfvars"

# Deploy
terraform apply -var-file="terraform.tfvars"
```

### **2. Note the Outputs**

After deployment, save these URLs:

```powershell
# Get workspace URLs
terraform output databricks_workspace_url          # Primary workspace
terraform output analytics_workspace_url           # Analytics workspace
terraform output unity_catalog_metastore_id       # Metastore ID
```

### **3. Upload Notebooks**

#### **To PRIMARY Workspace:**
1. Open Primary workspace URL
2. Navigate to Workspace → Users → Your User
3. Import `01-data-ingestion-primary-workspace.ipynb`

#### **To ANALYTICS Workspace:**
1. Open Analytics workspace URL
2. Navigate to Workspace → Users → Your User
3. Import `02-cross-workspace-access-analytics.ipynb`

## 📝 **Demo Workflow**

### **Phase 1: Data Ingestion (Primary Workspace)**

1. **Open Primary Workspace**
   - URL from: `terraform output databricks_workspace_url`

2. **Run Notebook**: `01-data-ingestion-primary-workspace.ipynb`
   - Creates 3 Delta tables in Unity Catalog:
     - `shared_data.samples.customers` (10 records)
     - `shared_data.samples.products` (10 records)
     - `shared_data.samples.transactions` (12 records)
   - Creates view: `shared_data.samples.customer_transactions`

3. **Key Points to Highlight:**
   - Three-level namespace: `catalog.schema.table`
   - Delta Lake format with ACID transactions
   - Table partitioning for performance
   - View creation for data lineage

### **Phase 2: Cross-Workspace Access (Analytics Workspace)**

1. **Open Analytics Workspace**
   - URL from: `terraform output analytics_workspace_url`
   - **Different workspace, same metastore!**

2. **Run Notebook**: `02-cross-workspace-access-analytics.ipynb`
   - Accesses tables created in Primary workspace
   - No data movement or replication needed
   - Performs analytics on shared data

3. **Key Points to Highlight:**
   - **Zero data duplication** - Same tables, different workspace
   - **Instant access** - No ETL pipelines needed
   - **Consistent security** - Permissions managed centrally
   - **Full analytics capabilities** - Joins, aggregations, ML features

### **Phase 3: Unity Catalog Features Demo**

#### **A. Data Lineage**
```sql
-- In either workspace, run:
DESCRIBE HISTORY shared_data.samples.transactions;

-- View table metadata
DESCRIBE EXTENDED shared_data.samples.customers;
```

#### **B. Permissions Management**
```sql
-- Grant SELECT on catalog (from Primary workspace)
GRANT USE CATALOG, USE SCHEMA ON CATALOG shared_data TO `account users`;
GRANT SELECT ON SCHEMA shared_data.samples TO `account users`;

-- Show grants
SHOW GRANTS ON CATALOG shared_data;
SHOW GRANTS ON TABLE shared_data.samples.customers;
```

#### **C. Data Discovery**
```sql
-- Search for tables across all catalogs
SHOW TABLES IN shared_data.samples;

-- Find tables with specific columns
SHOW COLUMNS IN shared_data.samples.customers;
```

#### **D. Time Travel & Versioning**
```sql
-- View table history
DESCRIBE HISTORY shared_data.samples.transactions;

-- Query previous version
SELECT * FROM shared_data.samples.transactions VERSION AS OF 1;

-- Query as of timestamp
SELECT * FROM shared_data.samples.transactions TIMESTAMP AS OF '2024-01-01';
```

## 🎯 **Unity Catalog Value Propositions**

### **1. Cross-Workspace Data Sharing**
- ✅ **Single Source of Truth**: No data duplication
- ✅ **Real-Time Access**: Changes visible immediately
- ✅ **Cost Efficient**: No storage duplication or sync jobs
- ✅ **Simplified Architecture**: Fewer data pipelines

### **2. Centralized Governance**
- ✅ **Unified Permissions**: Manage access in one place
- ✅ **Audit Logging**: Track all data access
- ✅ **Data Lineage**: Understand data flows
- ✅ **Discovery**: Find and understand data assets

### **3. Multi-Team Collaboration**
- ✅ **Data Engineering Team**: Ingests and curates data
- ✅ **Data Science Team**: Builds models on shared data
- ✅ **Analytics Team**: Creates dashboards and reports
- ✅ **Governance Team**: Manages permissions and policies

### **4. Enterprise Features**
- ✅ **Row/Column Security**: Fine-grained access control
- ✅ **Data Masking**: PII protection
- ✅ **Delta Sharing**: External data sharing
- ✅ **Multi-Cloud**: Works across Azure, AWS, GCP

## 📊 **Sample Use Cases**

### **Use Case 1: E-Commerce Analytics**
- **Primary Workspace**: Ingests orders, customers, products
- **Analytics Workspace**: Builds recommendation models
- **BI Tools**: Connect via SQL Warehouse for dashboards
- **Result**: Single customer view across all teams

### **Use Case 2: IoT Data Platform**
- **Primary Workspace**: Ingests sensor data, enriches
- **Analytics Workspace**: Predictive maintenance models
- **Data Science Workspace**: Anomaly detection
- **Result**: Real-time insights without data duplication

### **Use Case 3: Financial Services**
- **Primary Workspace**: Ingests transactions, accounts
- **Analytics Workspace**: Fraud detection models
- **Compliance Workspace**: Audit and reporting
- **Result**: Centralized compliance and governance

## 🧪 **Advanced Demonstrations**

### **1. Row-Level Security**
```sql
-- Create row-filtered view for specific country
CREATE VIEW shared_data.samples.customers_usa AS
SELECT * FROM shared_data.samples.customers
WHERE country = 'USA';

-- Grant access to US-only view
GRANT SELECT ON VIEW shared_data.samples.customers_usa TO `us_team`;
```

### **2. Column Masking**
```sql
-- Create view with masked PII
CREATE VIEW shared_data.samples.customers_masked AS
SELECT 
    customer_id,
    CONCAT(SUBSTRING(customer_name, 1, 1), '***') as customer_name,
    CONCAT('***@', SUBSTRING(email, LOCATE('@', email) + 1)) as email,
    country,
    signup_date
FROM shared_data.samples.customers;
```

### **3. Dynamic Views**
```sql
-- Create dynamic view based on current user
CREATE VIEW shared_data.samples.my_customers AS
SELECT * FROM shared_data.samples.customers
WHERE country = current_user_country();  -- Custom function
```

## 📈 **Performance Optimizations**

### **1. Z-Ordering**
```sql
-- Optimize for common query patterns
OPTIMIZE shared_data.samples.transactions
ZORDER BY (customer_id, transaction_date);
```

### **2. Liquid Clustering**
```sql
-- Create table with liquid clustering
CREATE TABLE shared_data.samples.orders
CLUSTER BY (order_date, customer_id)
AS SELECT * FROM source_orders;
```

### **3. Materialized Views**
```sql
-- Create pre-aggregated view
CREATE MATERIALIZED VIEW shared_data.samples.daily_revenue AS
SELECT 
    DATE(transaction_date) as date,
    SUM(total_amount) as revenue,
    COUNT(*) as transaction_count
FROM shared_data.samples.transactions
GROUP BY DATE(transaction_date);
```

## 🔒 **Security Best Practices**

1. **Principle of Least Privilege**
   - Grant minimum required permissions
   - Use groups instead of individual users

2. **Regular Audits**
   - Review grants regularly
   - Monitor data access patterns

3. **Data Classification**
   - Tag sensitive data
   - Apply appropriate controls

4. **Separation of Duties**
   - Data engineers create tables
   - Data stewards manage permissions
   - Analysts consume data

## 📚 **Additional Resources**

- [Unity Catalog Documentation](https://docs.databricks.com/data-governance/unity-catalog/index.html)
- [Delta Lake Documentation](https://docs.delta.io/)
- [Databricks Best Practices](https://docs.databricks.com/best-practices/index.html)
- [Unity Catalog REST API](https://docs.databricks.com/api/azure/workspace/unitycatalog)

## 🎓 **Training Path**

### **Level 1: Fundamentals**
1. Complete Lab 1-3 (Environment & Basic Resources)
2. Run both notebooks
3. Explore Unity Catalog UI

### **Level 2: Intermediate**
4. Complete Lab 7-9 (Unity Catalog deep dive)
5. Implement custom permissions
6. Create additional catalogs and schemas

### **Level 3: Advanced**
7. Implement row/column security
8. Set up Delta Sharing
9. Configure external locations
10. Integrate with BI tools

---

**Questions or Issues?** Check the troubleshooting section in the main README or create an issue.