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

```powershell
$env:NO_PROXY    = "avivacloud.com"
$env:VAULT_ADDR  = "https://vault.management.aws-euw1-np.avivacloud.com"

#   Get your vault token.

vault auth -method=ldap username=$env:username

#   Secrets: add the values for these interactively but DO NOT check into Source Control.

$env:VAULT_TOKEN           = ""
$env:AWS_ACCESS_KEY_ID     = ""
$env:AWS_SECRET_ACCESS_KEY = ""

#   Job parameters.

$environment   = 'platformtest'
$account       = '445906556292'
$clientvpc     = 'client-workload1'
$identifier    = 'euw1zlukdbtm104'

$aws_role_arn  = "arn:aws:iam::$($account):role/cloud-operations-dba/cloud-operations-dba-deployer"
$aws_s3_bucket = "aviva-$($clientvpc)-$($environment)-cloud-operations-dba"
$aws_state_key = "tfstate/rds/$($identifier).tfstate"
$region        = "eu-west-1"

#   terraform Initialise.

terraform get -update

terraform init -upgrade=false -backend=true -backend-config='bucket=$aws_s3_bucket' -backend-config='key=$aws_state_key' -backend-config='role_arn=$aws_role_arn' -backend-config='region=$region'

#   terraform Plan.

terraform plan -var-file ./environment.tfvars -var 'vault_token=$env:VAULT_TOKEN'
```
