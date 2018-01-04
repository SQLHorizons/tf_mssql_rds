provider "aws" {
  profile     = "${var.profile}"
  assume_role = {
    role_arn  = "arn:aws:iam::${var.client_account_number}:role/${var.team_name}/${var.team_name}-${var.team_role}"
  }
  region      = "${var.region}"
}

provider "aws" {
  alias       = "route-53-setup"
  profile     = "${var.profile}"
  region      = "${var.region}"  
}

provider "vault" {
  address = "${var.vault_address}"
  token   = "${var.vault_token}"
}

terraform {
  required_version = ">=0.9.11"
  backend "s3" {
    bucket  = "aviva-client-workload1-nonprod-cloud-operations-dba"
    key     = "tfstate/rds/euw1zlukdbtm101.tfstate"
    profile = "AWS-D-nonprod"
    role_arn = "arn:aws:iam::300820918606:role/cloud-operations-dba/cloud-operations-dba-deployer"
    region  = "eu-west-1"
  }
}

data "aws_security_group" "application" {
  name   = "managed"
}

#####
# DB
#####
module "tf_mssql_rds" {
  source = "../../../../tfmodules/rds/mssql/"

  identifier                 = "euw1zlukdbtm101"
  multi_az                   = true
   
  engine                     = "sqlserver-se"
  engine_version             = "13.00.4422.0.v1"
  instance_class             = "db.m4.large"

  allocated_storage          = 200
  storage_type               = "gp2"
  iops                       = 0

  #create_cidr_ingress_rule   = true
  #cidr_blocks                = "10.0.0.0/8"

  vpc_security_group_ids     = ["${data.aws_security_group.application.id}"]
  apply_immediately          = true
  auto_minor_version_upgrade = true

  tags                       = {
    Costcentre_Projectcode   = "9ISB3_74851"
    HSN                      = "DB TOOLS NPE AWD"
    Owner                    = "clouddatabaseteam@aviva.com"
    Schedule                 = "NSun0000-2359Mon0000-2359Tue0000-2359Wed0000-2359Thu0000-2359Fri0000-2359Sat0000-2359"
    Expiry                   = "2017-12-31"
    Name                     = "Template Script"
    Team                     = "${var.team_name}"
    Jira                     = ""
  }

  vpc_id                     = "${var.vpc_id}"
  team_name                  = "${var.team_name}"
  db_subnet_group_name       = "${var.db_subnet_group_name}"
  iam_role                   = "${var.iam_role}"
  secret                     = "${var.secret}"

  zone_id                    = "Z3FHCT1JYHVH0Q"
  domain_name                = "aws-db-conn.runway.aws-euw1-np.avivacloud.com"
  dns_alias                  = "test"

  alarm_action               = "${var.alarm_action}"
  region                     = "${var.region}"
}

output "alias" {
  description = "The Route 53 alias of the DB instance"
  value       = "${module.tf_mssql_rds.rds_db_instance_alias}"
}
