variable "aws_region" {
  description = "AWS region to deploy into"
  type        = string
  default     = "ap-south-1"
}

# ─── VPC ──────────────────────────────────────────────────────────────────────
variable "vpc_name" {
  description = "Name of the VPC"
  type        = string
  default     = "Sample-vpc"
}

variable "vpc_cidr" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones (must align with subnet CIDR lists)"
  type        = list(string)
  default     = ["ap-south-1a", "ap-south-1b"]
}

variable "public_subnet_cidrs" {
  description = "CIDRs for public subnets"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24"]
}

variable "private_subnet_cidrs" {
  description = "CIDRs for private subnets"
  type        = list(string)
  default     = ["10.0.10.0/24", "10.0.20.0/24"]
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
  default     = "sample-vm"
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

variable "ingress_rules" {
  description = "Ingress rules for the instance security group"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      description = "App"
      from_port   = 3000
      to_port     = 3000
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
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

# ─── Tags ─────────────────────────────────────────────────────────────────────
variable "environment" {
  description = "Environment label (dev / staging / prod)"
  type        = string
  default     = ""
}

variable "project" {
  description = "Project name used in common tags"
  type        = string
  default     = "Sampleproject"
}
