# DB instance
output "rds_db_instance_address" {
  description = "The address of the RDS instance"
  value       = "${aws_db_instance.rds.address}"
}

output "rds_db_instance_arn" {
  description = "The ARN of the RDS instance"
  value       = "${aws_db_instance.rds.arn}"
}

output "rds_db_instance_availability_zone" {
  description = "The availability zone of the RDS instance"
  value       = "${aws_db_instance.rds.availability_zone}"
}

output "rds_db_instance_endpoint" {
  description = "The connection endpoint"
  value       = "${aws_db_instance.rds.endpoint}"
}

output "rds_db_instance_password" {
  description = "Password for the master DB user. Note that this may show up in logs, and it will be stored in the state file"
  value       = "${random_id.password.hex}"
}

output "rds_db_instance_hosted_zone_id" {
  description = "The canonical hosted zone ID of the DB instance (to be used in a Route 53 Alias record)"
  value       = "${aws_db_instance.rds.hosted_zone_id}"
}

output "rds_db_instance_alias" {
  description = "The Route 53 alias of the DB instance"
  value       = "${aws_route53_record.alias.name}"
}

#output "rds_db_instance_fqdn" {
#  description = "The Route 53 fqdn of the DB instance"
#  value       = "${aws_route53_record.alias.fqdn}"
#}

output "rds_db_instance_id" {
  description = "The RDS instance ID"
  value       = "${aws_db_instance.rds.id}"
}

output "rds_db_instance_resource_id" {
  description = "The RDS Resource ID of this instance"
  value       = "${aws_db_instance.rds.resource_id}"
}

output "rds_db_instance_status" {
  description = "The RDS instance status"
  value       = "${aws_db_instance.rds.status}"
}

output "rds_db_instance_port" {
  description = "The database port"
  value       = "${aws_db_instance.rds.port}"
}

output "rds_db_instance_security_group_id" {
  description = "The database port"
  value       = "${aws_security_group.rds_sg.id}"
}
