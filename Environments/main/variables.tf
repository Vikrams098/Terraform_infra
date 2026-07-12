variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1"
}

# ─── VPC ──────────────────────────────────────────────────────────────────────
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "Kv's-vpc-main"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.1.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones (must align with subnet CIDR lists)"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public subnets"
  type        = list(string)
  default     = ["10.1.1.0/24", "10.1.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs for private subnets"
  type        = list(string)
  default     = ["10.1.10.0/24", "10.1.20.0/24"]
}

variable "enable_nat_gateway" {
  description = "Whether to create a NAT Gateway"
  type        = bool
  default     = true
}

# ─── EC2 ──────────────────────────────────────────────────────────────────────
variable "instance_name" {
  description = "Name tag for the EC2 instance"
  type        = string
  default     = "Kv's-vm-main"
}

variable "ami_id" {
  description = "AMI ID (e.g. Amazon Linux 2023 in ap-south-1: ami-0f9235932f10668d4)"
  type        = string
  default     = "ami-01a00762f46d584a1"
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "c7i-flex.large"
}

variable "key_name" {
  description = "Name of an existing EC2 key pair for SSH"
  type        = string
  default     = "Mumbai"
}

# ─── ALB / ASG / DNS ────────────────────────────────────────────────────────
variable "domain_name" {
  description = "Fully-qualified subdomain this environment serves (delegated to Route 53 at the registrar)"
  type        = string
  default     = "app.awsprojects.cloud"
}

variable "asg_min_size" {
  description = "Minimum number of app instances behind the ALB"
  type        = number
  default     = 2
}

variable "asg_max_size" {
  description = "Maximum number of app instances behind the ALB"
  type        = number
  default     = 4
}

variable "asg_desired_capacity" {
  description = "Desired number of app instances behind the ALB"
  type        = number
  default     = 2
}

# ─── RDS ──────────────────────────────────────────────────────────────────────
variable "db_name" {
  description = "Name of the initial Postgres database"
  type        = string
  default     = "kvscafe"
}

variable "db_username" {
  description = "RDS master username (must not be a reserved word like 'admin')"
  type        = string
  default     = "kvscafe_admin"
}

variable "db_instance_class" {
  description = "RDS instance class"
  type        = string
  default     = "db.t4g.micro"
}

variable "db_allocated_storage" {
  description = "RDS allocated storage in GiB"
  type        = number
  default     = 20
}

variable "db_engine_version" {
  description = "Postgres major version"
  type        = string
  default     = "16"
}

variable "db_multi_az" {
  description = "Whether to deploy a standby RDS replica in a second AZ"
  type        = bool
  default     = false
}

variable "db_deletion_protection" {
  description = "Prevent accidental terraform destroy of the RDS instance"
  type        = bool
  default     = true
}

variable "db_skip_final_snapshot" {
  description = "Skip taking a final RDS snapshot on deletion"
  type        = bool
  default     = false
}

variable "db_backup_retention_period" {
  description = "Automated backup retention, in days (new AWS accounts are capped at 1 by the free-tier restriction)"
  type        = number
  default     = 1
}

# ─── Tags ─────────────────────────────────────────────────────────────────────
variable "environment" {
  description = "Environment label (dev / staging / prod)"
  type        = string
  default     = "main"
}

variable "project" {
  description = "Project name used in common tags"
  type        = string
  default     = "Kv's-project"
}
