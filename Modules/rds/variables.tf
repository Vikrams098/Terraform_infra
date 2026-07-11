variable "vpc_id" {
  description = "VPC ID where the RDS security group will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs for the DB subnet group (must span at least 2 AZs)"
  type        = list(string)
}

variable "allowed_security_group_id" {
  description = "Security group ID (e.g. the app EC2 instance's SG) allowed to reach Postgres on 5432"
  type        = string
}

variable "identifier" {
  description = "RDS instance identifier, also used to name dependent resources"
  type        = string
}

variable "db_name" {
  description = "Name of the initial database created on the instance"
  type        = string
}

variable "db_username" {
  description = "Master username (must not be a reserved word like 'admin')"
  type        = string
}

variable "engine_version" {
  description = "Postgres major version"
  type        = string
  default     = "16"
}

variable "instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "allocated_storage" {
  description = "Allocated storage in GiB"
  type        = number
  default     = 20
}

variable "storage_type" {
  description = "EBS storage type backing the instance"
  type        = string
  default     = "gp3"
}

variable "multi_az" {
  description = "Whether to deploy a standby replica in a second AZ"
  type        = bool
  default     = false
}

variable "backup_retention_period" {
  description = "Automated backup retention, in days"
  type        = number
  default     = 7
}

variable "deletion_protection" {
  description = "Prevent accidental terraform destroy of the instance"
  type        = bool
  default     = true
}

variable "skip_final_snapshot" {
  description = "Skip taking a final snapshot on deletion (false = safer, but leaves a snapshot to clean up manually)"
  type        = bool
  default     = false
}

variable "apply_immediately" {
  description = "Apply modifications immediately instead of during the next maintenance window"
  type        = bool
  default     = false
}

variable "tags" {
  description = "Common tags applied to every resource"
  type        = map(string)
  default     = {}
}
