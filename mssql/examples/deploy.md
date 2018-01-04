Microsoft SQL Server RDS Deployment Guide
=========================================

This directory contains example deployment templates for execution with the tf_mssql_rds module.

Contents
--------

* deploy.md - This read me guide.
* main.tf - The main terraform deployment script.
* variables.tf - List of variables used within the scripts.
* environment.tfvars - Environment specific  values, this example is for non-prod.

Usage
-----

```hcl
$env:NO_PROXY   = "avivacloud.com"
$env:VAULT_ADDR = "https://vault.management.aws-euw1-np.avivacloud.com"

vault auth -method=ldap username=$env:username

terraform get
terraform init
terraform plan -var-file ./environment.tfvars -var 'vault_token=1812450e-6381-de64-79d6-b58d66cc9f32'
```
