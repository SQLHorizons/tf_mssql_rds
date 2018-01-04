variable "identifier" {
  description = "The name of the RDS instance, if omitted, Terraform will assign a random, unique identifier"
}

variable "port" {
  description = "The port on which the DB accepts connections"
  default     = 1433
}

variable "create_cidr_ingress_rule" {
  description = "If set to true, create an cidr ingress rule for RDS"
  default = false
}

variable "cidr_blocks" {
  description = "List of cidr blocks"
  default = "0"
}

variable "vpc_security_group_ids" {
  type        = "list"
  description = "List of VPC security groups to associate"
  default     = []
}

variable "tags" {
  description = "A mapping of tags to assign to all resources"
  default     = {}
}

variable "vpc_id" {
  description = "The id of the VPC that the RDS instance belongs to."
}

resource "aws_security_group" "rds_sg_1" {
  count       = "${var.create_cidr_ingress_rule ? 0 : 1}"

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
    security_groups = ["${var.vpc_security_group_ids}"]
  }

  tags = "${var.tags}"
}

resource "aws_security_group" "rds_sg_2" {
  count       = "${var.create_cidr_ingress_rule ? 1 : 0}"

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
    security_groups = ["${var.vpc_security_group_ids}"]
  }

  ingress {
    from_port       = "${var.port}"
    to_port         = "${var.port}"
    protocol        = "tcp"
    cidr_blocks     = ["${var.cidr_blocks}"]
  }

  tags = "${var.tags}"
}

output "id" {
  description = "The aws security group id"
  value       = "${var.create_cidr_ingress_rule ? aws_security_group.rds_sg_2.id : aws_security_group.rds_sg_1.id}"
}
