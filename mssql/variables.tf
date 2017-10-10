variable "identifier" {
  description = "The name of the RDS instance, if omitted, Terraform will assign a random, unique identifier"
}

variable "allocated_storage" {
  description = "The allocated storage (or disk_size) in gigabytes"
}

variable "storage_type" {
  description = "One of 'standard' (magnetic), 'gp2' (general purpose SSD), or 'io1' (provisioned IOPS SSD). The default is 'io1' if iops is specified, 'standard' if not. Note that this behaviour is different from the AWS web console, where the default is 'gp2'."
  default     = "gp2"
}

variable "engine" {
  description = "The database engine to use"
}

variable "engine_version" {
  description = "The engine version to use"
}

variable "instance_class" {
  description = "The instance type of the RDS instance"
}

variable "name" {
  description = "The DB name to create. If omitted, no database is created initially"
  default     = ""
}

variable "username" {
  description = "Username for the master DB user"
  default     = "dbAdmin"
}

variable "password" {
  description = "Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file"
}

variable "port" {
  description = "The port on which the DB accepts connections"
  default     = 1433
}

variable "vpc_security_group_ids" {
  type        = "list"
  description = "List of VPC security groups to associate"
  default     = []
}

variable "multi_az" {
  description = "Specifies if the RDS instance is multi-AZ"
  default     = false
}

variable "iops" {
  description = "The amount of provisioned IOPS. Setting this implies a storage_type of 'io1'"
  default     = 0
}

variable "publicly_accessible" {
  description = "Bool to control if instance is publicly accessible"
  default     = false
}

variable "allow_major_version_upgrade" {
  description = "Indicates that major version upgrades are allowed. Changing this parameter does not result in an outage and the change is asynchronously applied as soon as possible"
  default     = false
}

variable "auto_minor_version_upgrade" {
  description = "Indicates that minor engine upgrades will be applied automatically to the DB instance during the maintenance window"
  default     = false
}

variable "apply_immediately" {
  description = "Specifies whether any database modifications are applied immediately, or during the next maintenance window"
  default     = false
}

variable "maintenance_window" {
  description = "The window to perform maintenance in. Syntax: 'ddd:hh24:mi-ddd:hh24:mi'. Eg: 'Mon:00:00-Mon:03:00'"
  default     = "sun:03:23-sun:07:43"
}

variable "skip_final_snapshot" {
  description = "Determines whether a final DB snapshot is created before the DB instance is deleted. If true is specified, no DBSnapshot is created. If false is specified, a DB snapshot is created before the DB instance is deleted, using the value from final_snapshot_identifier"
  default     = true
}

variable "copy_tags_to_snapshot" {
  description = "On delete, copy all Instance tags to the final snapshot (if final_snapshot_identifier is specified)"
  default     = true
}

variable "backup_retention_period" {
  description = "The days to retain backups for"
  default     = 35
}

variable "backup_window" {
  description = "The daily time range (in UTC) during which automated backups are created if they are enabled. Example: '09:46-10:16'. Must not overlap with maintenance_window"
  default     = "01:07-03:07"
}

variable "iam_role" {
  description = "The ,name of the iam role that has the correct rights to backup databases to the cloud operations s3 bucket."
  default     = "dba-e24f2a45f4d2"
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  default     = {}
}

# DB parameter group
variable "timezone" {
  description = "Time zone of the DB instance. timezone is currently only supported by Microsoft SQL Server. The timezone can only be set on creation."
  default = "GMT Standard Time"
}

variable "license_model" {
  description = "License model information for this DB instance."
  default     = "bring-your-own-license"
}

variable "db_subnet_group_name" {
  description = "Name of DB subnet group. DB instance will be created in the VPC associated with the DB subnet group. If unspecified, will be created in the default VPC"
  default     = "client-rds"
}

variable "monitoring_interval" {
  description = "The interval, in seconds, between points when Enhanced Monitoring metrics are collected for the DB instance. To disable collecting Enhanced Monitoring metrics, specify 0. The default is 0. Valid Values: 0, 1, 5, 10, 15, 30, 60."
  default     = 0
}

variable "alarm_action" {
  description = "Action to execute when this alarm transitions into an ALARM state from any other state. Specified as an Amazon Resource Number (ARN)."
  default     = "arn:aws:sns:eu-west-1:459714977904:ukds-rds-monitoring"
}

variable "vpc_id" {
  description = "The id of the VPC that the RDS instance belongs to."
}

variable "team_name" {
  description = "Owning team. The team name as provided by cloud operations when your team was created."
}

#DNS
variable "zone_id" {
  description = "The ID of the hosted zone to contain this record."
  default     = ""
}

variable "dns_alias" {
  description = "The host label of the alias DNS record."
  default     = ""
}

variable "dns_ttl" {
  description = "The TTL of the alias DNS record."
  default = "300"
}

variable "domain_name" {
  description = "Domain name of the alias DNS record."
  default     = ""
}
