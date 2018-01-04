data "aws_security_group" "DBAdmin" {
  name = "${var.team_name}-ec2"
}

data "aws_iam_role" "db_role" {
  name = "${var.iam_role}"
}

resource "random_id" "password" {
byte_length = 8
}

resource "vault_generic_secret" "rds_vault_access" {
  path = "${var.secret}/${var.identifier}"

  data_json = <<EOT
{
  "dbAdmin": "${random_id.password.hex}",
  "endpoint": "${aws_route53_record.alias.name}"
}
EOT
}

resource "aws_kms_key" "rds-instance-key" {
  description = "KMS key for rds instance - ${var.identifier}"
  tags = "${var.tags}"
}

resource "aws_kms_alias" "rds-instance-key-alias" {
  name          = "alias/${var.identifier}"
  target_key_id = "${aws_kms_key.rds-instance-key.arn}"
}

module "rds_sg" {
  source = "./rds_sg/"

  create_cidr_ingress_rule = "${var.create_cidr_ingress_rule}"
  identifier               = "${var.identifier}"
  vpc_id                   = "${var.vpc_id}"
  port                     = "${var.port}"

  vpc_security_group_ids   = ["${data.aws_security_group.DBAdmin.id}","${var.vpc_security_group_ids}"]
  cidr_blocks              = "${var.cidr_blocks}"

  tags                     = "${var.tags}"
}

resource "aws_db_option_group" "option_group" {
  name                        = "${var.identifier}"
  option_group_description    = "Option Group for ${var.identifier} version ${var.engine_version}"
  engine_name                 = "${var.engine}"
  major_engine_version        = "${substr(var.engine_version, 0, 5)}"

  tags = "${var.tags}"

  option {
    option_name = "SQLSERVER_BACKUP_RESTORE"
    option_settings {
      name = "IAM_ROLE_ARN"
      value = "${data.aws_iam_role.db_role.arn}"
    }
  }
}

resource "aws_db_parameter_group" "parameter_group" {
  name        = "${var.identifier}"
  family      = "${var.engine}-${substr(var.engine_version, 0, 4)}"
  description = "Parameter group for ${var.identifier}"

  tags = "${var.tags}"

    parameter {
    name         = "rds.force_ssl"
    value        = 1
    apply_method = "pending-reboot"
  }
  
  parameter {
    name         = "cost threshold for parallelism"
    value        = 100
    apply_method = "immediate"
  }

  parameter {
    name         = "fill factor (%)"
    value        = 90
    apply_method = "pending-reboot"
  }
}

resource "aws_db_instance" "rds" {
  identifier                  = "${var.identifier}"

  engine                      = "${var.engine}"
  engine_version              = "${var.engine_version}"
  license_model               = "${var.license_model}"
  timezone                    = "${var.timezone}"
  instance_class              = "${var.instance_class}"
  allocated_storage           = "${var.allocated_storage}"
  storage_type                = "${var.storage_type}"

  storage_encrypted           = "${aws_kms_key.rds-instance-key.arn == "" ? false : true}"
  kms_key_id                  = "${aws_kms_key.rds-instance-key.arn}"

  name                        = "${var.name}"
  username                    = "${var.username}"
  password                    = "${random_id.password.hex}"
  port                        = "${var.port}"

  vpc_security_group_ids      = ["${module.rds_sg.id}"]

  db_subnet_group_name        = "${var.db_subnet_group_name}"
  option_group_name           = "${aws_db_option_group.option_group.name}"
  parameter_group_name        = "${aws_db_parameter_group.parameter_group.name}"

  multi_az                    = "${var.multi_az}"
# availability_zone           = "${var.region}${substr(var.identifier, 4, 1)}"
  iops                        = "${var.iops}"
  publicly_accessible         = "${var.publicly_accessible}"
  monitoring_interval         = "${var.monitoring_interval}"  
  
  allow_major_version_upgrade = "${var.allow_major_version_upgrade}"
  auto_minor_version_upgrade  = "${var.auto_minor_version_upgrade}"
  apply_immediately           = "${var.apply_immediately}"
  maintenance_window          = "${var.maintenance_window}"
  skip_final_snapshot         = "${var.skip_final_snapshot}"
  copy_tags_to_snapshot       = "${var.copy_tags_to_snapshot}"

  backup_retention_period     = "${var.backup_retention_period}"
  backup_window               = "${var.backup_window}"

  tags = "${var.tags}"
}

resource "aws_route53_record" "alias" {
  provider                    = "aws.route-53-setup"
  zone_id                     = "${var.zone_id}"
  name                        = "${var.dns_alias}.${var.domain_name}"
  type                        = "CNAME"
  ttl                         = "${var.dns_ttl}"
  records                     = ["${aws_db_instance.rds.address}"]
}

resource "aws_cloudwatch_metric_alarm" "CPU-Utilization-Warning" {
  alarm_name                  = "${var.identifier} CPU Utilization Warning"
  comparison_operator         = "GreaterThanOrEqualToThreshold"
  evaluation_periods          = "3"
  metric_name                 = "CPUUtilization"
  namespace                   = "AWS/RDS"
  period                      = "300"
  statistic                   = "Average"
  threshold                   = "80"
  alarm_description           = "RDS CPU Utilization Warning on ${var.identifier}"
  dimensions {
    DBInstanceIdentifier      = "${var.identifier}"
  }
  alarm_actions               = ["${var.alarm_action}"]
  insufficient_data_actions   = []
}

resource "aws_cloudwatch_metric_alarm" "CPU-Utilization-Critical" {
  alarm_name                  = "${var.identifier} CPU Utilization Critical"
  comparison_operator         = "GreaterThanOrEqualToThreshold"
  evaluation_periods          = "1"
  metric_name                 = "CPUUtilization"
  namespace                   = "AWS/RDS"
  period                      = "120"
  statistic                   = "Average"
  threshold                   = "95"
  alarm_description           = "RDS CPU Utilization Critical on ${var.identifier}"
  dimensions {
    DBInstanceIdentifier      = "${var.identifier}"
  }
  alarm_actions               = ["${var.alarm_action}"]
  insufficient_data_actions   = []
}

resource "aws_cloudwatch_metric_alarm" "Free-Storage-Warning" {
  alarm_name                  = "${var.identifier} Free-Storage-Warning"
  comparison_operator         = "LessThanThreshold"
  evaluation_periods          = "2"
  metric_name                 = "FreeStorageSpace"
  namespace                   = "AWS/RDS"
  period                      = "300"
  statistic                   = "Average"
  threshold                   = "${102.4*var.allocated_storage}"
  alarm_description           = "RDS Free Storage Warning on ${var.identifier}"
  dimensions {
    DBInstanceIdentifier      = "${var.identifier}"
  }
  alarm_actions               = ["${var.alarm_action}"]
  insufficient_data_actions   = []
}

resource "aws_cloudwatch_metric_alarm" "Read-Latency-Warning" {
  alarm_name                  = "${var.identifier} Read Latency Warning"
  comparison_operator         = "GreaterThanOrEqualToThreshold"
  evaluation_periods          = "2"
  metric_name                 = "ReadLatency"
  namespace                   = "AWS/RDS"
  period                      = "300"
  statistic                   = "Average"
  threshold                   = "0.010"
  alarm_description           = "RDS Read Latency Warning on ${var.identifier}"
  dimensions {
    DBInstanceIdentifier      = "${var.identifier}"
  }
  alarm_actions               = ["${var.alarm_action}"]
  insufficient_data_actions   = []
}

resource "aws_cloudwatch_metric_alarm" "Read-Latency-Critical" {
  alarm_name                  = "${var.identifier} Read Latency Critical"
  comparison_operator         = "GreaterThanOrEqualToThreshold"
  evaluation_periods          = "1"
  metric_name                 = "ReadLatency"
  namespace                   = "AWS/RDS"
  period                      = "300"
  statistic                   = "Maximum"
  threshold                   = "0.050"
  alarm_description           = "RDS Read Latency Critical on ${var.identifier}"
  dimensions {
    DBInstanceIdentifier      = "${var.identifier}"
  }
  alarm_actions               = ["${var.alarm_action}"]
  insufficient_data_actions   = []
}

resource "aws_cloudwatch_metric_alarm" "Write-Latency-Warning" {
  alarm_name                  = "${var.identifier} Write Latency Warning"
  comparison_operator         = "GreaterThanOrEqualToThreshold"
  evaluation_periods          = "2"
  metric_name                 = "WriteLatency"
  namespace                   = "AWS/RDS"
  period                      = "300"
  statistic                   = "Average"
  threshold                   = "0.010"
  alarm_description           = "RDS Write Latency Warning on ${var.identifier}"
  dimensions {
    DBInstanceIdentifier      = "${var.identifier}"
  }
  alarm_actions               = ["${var.alarm_action}"]
  insufficient_data_actions   = []
}

resource "aws_cloudwatch_metric_alarm" "Write-Latency-Critical" {
  alarm_name                  = "${var.identifier} Write Latency Critical"
  comparison_operator         = "GreaterThanOrEqualToThreshold"
  evaluation_periods          = "1"
  metric_name                 = "WriteLatency"
  namespace                   = "AWS/RDS"
  period                      = "300"
  statistic                   = "Maximum"
  threshold                   = "0.050"
  alarm_description           = "RDS Write Latency Critical on ${var.identifier}"
  dimensions {
    DBInstanceIdentifier      = "${var.identifier}"
  }
  alarm_actions               = ["${var.alarm_action}"]
  insufficient_data_actions   = []
}

resource "aws_cloudwatch_metric_alarm" "Free-Memory-Warning" {
  alarm_name                  = "${var.identifier} Free-Memory-Warning"
  comparison_operator         = "LessThanThreshold"
  evaluation_periods          = "2"
  metric_name                 = "FreeableMemory"
  namespace                   = "AWS/RDS"
  period                      = "1800"
  statistic                   = "Sum"
  threshold                   = "1024"
  alarm_description           = "RDS Free Memory Warning on ${var.identifier}"
  dimensions {
    DBInstanceIdentifier      = "${var.identifier}"
  }
  alarm_actions               = ["${var.alarm_action}"]
  insufficient_data_actions   = []
}
