profile               = "AWS-D-nonprod"
team_name             = "cloud-operations-dba"
team_role             = "deployer"
client_account_number = "300820918606"
managment_account     = "906261169288"
region                = "eu-west-1"

vpc_id                = "vpc-0e03936a"
db_subnet_group_name  = "client-rds"
iam_role              = "cloud-operations-dba-d030699c01f1"
alarm_action          = "arn:aws:sns:eu-west-1:300820918606:ukds-rds-monitoring"

vault_address         = "https://vault.management.aws-euw1-np.avivacloud.com"
secret                = "team_aws_direct_operations_dba_generic"
