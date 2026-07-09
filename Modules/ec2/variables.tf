variable "instance_name" {
  description = "Name tag for the EC2 instance and related resources"
  type        = string
}

variable "ami_id" {
  description = "AMI ID to launch (e.g. latest Amazon Linux 2 for the region)"
  type        = string
}

variable "instance_type" {
  description = "EC2 instance type"
  type        = string
  default     = "c7i-flex.large"
}

variable "subnet_id" {
  description = "Subnet in which to place the instance"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID where the security group will be created"
  type        = string
}

variable "key_name" {
  description = "Name of an existing EC2 key pair for SSH access (leave empty to skip)"
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

variable "ingress_rules" {
  description = "List of ingress rules for the security group"
  type = list(object({
    description = string
    from_port   = number
    to_port     = number
    protocol    = string
    cidr_blocks = list(string)
  }))
  default = [
    {
      description = "SSH"
      from_port   = 22
      to_port     = 22
      protocol    = "tcp"
      cidr_blocks = ["0.0.0.0/0"]
    }
  ]
}

variable "tags" {
  description = "Common tags applied to every resource"
  type        = map(string)
  default     = {}
}
