variable "name" {
  description = "Base name used for the ASG and dependent resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "private_subnet_ids" {
  description = "Private subnet IDs the app instances launch into (must span at least 2 AZs)"
  type        = list(string)
}

variable "ami_id" {
  description = "AMI ID to launch (e.g. latest Amazon Linux 2023 for the region)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type for launch template instances"
  type        = string
  default     = "c7i-flex.large"
}

variable "key_name" {
  description = "Name of an existing EC2 key pair for SSH access"
  type        = string
  default     = "Mumbai"
}

variable "root_volume_type" {
  description = "EBS volume type for the root disk"
  type        = string
  default     = "gp3"
}

variable "root_volume_size" {
  description = "Root EBS volume size in GiB"
  type        = number
  default     = 30
}

variable "app_port" {
  description = "Port the application listens on inside each instance"
  type        = number
  default     = 3000
}

variable "alb_security_group_id" {
  description = "Security group ID of the ALB — the only allowed source for app_port ingress"
  type        = string
}

variable "target_group_arn" {
  description = "ALB target group ARN new instances register with"
  type        = string
}

variable "min_size" {
  description = "Minimum number of instances in the group"
  type        = number
  default     = 2
}

variable "max_size" {
  description = "Maximum number of instances in the group"
  type        = number
  default     = 4
}

variable "desired_capacity" {
  description = "Desired number of instances in the group"
  type        = number
  default     = 2
}

variable "target_cpu_percent" {
  description = "Target average CPU utilization for the scaling policy"
  type        = number
  default     = 60
}

variable "user_data" {
  description = "Cloud-init script run on first boot (defaults to installing and starting Docker on AL2023)"
  type        = string
  default     = <<-EOF
    #!/bin/bash
    set -eux
    dnf update -y
    dnf install -y docker
    systemctl enable --now docker
    usermod -aG docker ec2-user
  EOF
}

variable "tags" {
  description = "Common tags applied to every resource"
  type        = map(string)
  default     = {}
}
