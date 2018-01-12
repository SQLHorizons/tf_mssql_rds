variable "identifier" {
  description = "The name of the RDS instance, if omitted, Terraform will assign a random, unique identifier"
}

variable "team_name" {
  description = "Environment setting: AWS Direct team to assume during execution of terraform script"
}

variable "team_role" {
  description = "Environment setting: AWS Direct role to assume during execution of terraform script"
}

variable "client_account_number" {
  description = "Environment setting: AWS account to connect to"
}

variable "vpc_id" {
  description = "Environment setting: the id of the VPC that the RDS instance belongs to."
}

variable "port" {
  description = "The port on which the DB accepts connections"
  default     = 1433
}

variable "db_subnet_group_name" {
  description = "Name of DB subnet group. DB instance will be created in the VPC associated with the DB subnet group. If unspecified, will be created in the default VPC"
}

variable "iam_role" {
  description = "The iam role used to enable rds to read and write to s3 bucket."
}

variable "secret" {
  description = "The vault secret backend to secure the password."
}

variable "alarm_action" {
  description = "Action to execute when this alarm transitions into an ALARM state from any other state. Specified as an Amazon Resource Number (ARN)."
}

#DNS
variable "dns_ttl" {
  description = "The TTL of the alias DNS record."
  default = "300"
}

variable "vault_address" {
  description = "URL address to vault store."
}

variable "region" {
  description = "Environment setting: Region to create the resource"
}
