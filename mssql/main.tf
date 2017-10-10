data "aws_security_group" "DBAdmin" {
  name = "${var.team_name}-ec2"
}

data "aws_iam_role" "db_role" {
  role_name = "${var.iam_role}"
}

resource "aws_kms_key" "rds-instance-key" {
  description = "KMS key for rds instance - ${var.identifier}"
  tags = "${var.tags}"
}

resource "aws_security_group" "rds_sg" {
  name        = "${var.identifier}"
  description = "Controls access to MS SQL RDS instances"
  vpc_id      = "${var.vpc_id}"

  egress {
    from_port       = 0
    to_port         = 0
    protocol        = "-1"
    cidr_blocks     = ["0.0.0.0/0"]
  }

  ingress {
    from_port       = "${var.port}"
    to_port         = "${var.port}"
    protocol        = "tcp"
    security_groups = ["${data.aws_security_group.DBAdmin.id}","${var.vpc_security_group_ids}"]
  }

  tags = "${var.tags}"
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
  password                    = "${var.password}"
  port                        = "${var.port}"

  vpc_security_group_ids      = ["${aws_security_group.rds_sg.id}"]
  db_subnet_group_name        = "${var.db_subnet_group_name}"
  option_group_name           = "${aws_db_option_group.option_group.name}"
  parameter_group_name        = "${aws_db_parameter_group.parameter_group.name}"

  multi_az                    = "${var.multi_az}"
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
