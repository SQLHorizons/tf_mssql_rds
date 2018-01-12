provider "aws" {
  version     = "1.1.0"
  assume_role = {
    role_arn  = "arn:aws:iam::${var.client_account_number}:role/${var.team_name}/${var.team_name}-${var.team_role}"
  }
  region      = "${var.region}"
}

provider "aws" {
  version = "1.1.0"
  alias   = "route-53-setup"
  region  = "${var.region}"  
}

provider "vault" {
  version = "1.0.0"
  address = "${var.vault_address}"
}

provider "random" {
  version = "1.1.0"
}

data "aws_security_group" "application" {
  name   = "managed"
}

#####
# DB
#####
module "tf_mssql_rds" {
# source = "git::https://stash.aviva.co.uk/scm/ukdb/tfmodules.git//rds//mssql?ref=tf_mssql_rds"
  source = "../../mssql"

  identifier                 = "${var.identifier}"
  multi_az                   = true
   
  engine                     = "sqlserver-se"
  engine_version             = "14.00.1000.169.v1"
  instance_class             = "db.m4.large"

  port                       = "${var.port}"

  allocated_storage          = 200
  storage_type               = "gp2"
  iops                       = 0

  vpc_security_group_ids     = ["${data.aws_security_group.application.id}"]
  apply_immediately          = true

  tags                       = {
    Costcentre_Projectcode   = "9ISB3_74851"
    HSN                      = "DB TOOLS NPE AWD"
    Owner                    = "clouddatabaseteam@aviva.com"
    Schedule                 = "NSun0000-2359Mon0000-2359Tue0000-2359Wed0000-2359Thu0000-2359Fri0000-2359Sat0000-2359"
    Expiry                   = "2018-01-31"
    Name                     = "Template Script"
    Team                     = "${var.team_name}"
    Jira                     = ""
  }

  vpc_id                     = "${var.vpc_id}"
  team_name                  = "${var.team_name}"
  db_subnet_group_name       = "${var.db_subnet_group_name}"
  iam_role                   = "${var.iam_role}"
  vault_alias                = "Test104.rds"
  secret                     = "${var.secret}"

  zone_id                    = "Z3FHCT1JYHVH0Q"
  domain_name                = "aws-db-conn.runway.aws-euw1-np.avivacloud.com"
  dns_alias                  = "test"

  alarm_action               = "${var.alarm_action}"
  region                     = "${var.region}"
}

resource "aws_security_group_rule" "clientPCs" {
  security_group_id = "${module.tf_mssql_rds.rds_db_instance_security_group_id}"
  type              = "ingress"
  from_port         = "${var.port}"
  to_port           = "${var.port}"
  protocol          = "tcp"
  cidr_blocks       = ["10.0.0.0/8"]
}
