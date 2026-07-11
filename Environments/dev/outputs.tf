output "vpc_id" {
  description = "VPC ID"
  value       = module.vpc.vpc_id
}

output "vpc_cidr" {
  description = "VPC CIDR block"
  value       = module.vpc.vpc_cidr
}

output "internet_gateway_id" {
  description = "Internet Gateway ID"
  value       = module.vpc.internet_gateway_id
}

output "public_subnet_ids" {
  description = "Public subnet IDs"
  value       = module.vpc.public_subnet_ids
}

output "private_subnet_ids" {
  description = "Private subnet IDs"
  value       = module.vpc.private_subnet_ids
}

output "nat_gateway_id" {
  description = "NAT Gateway ID"
  value       = module.vpc.nat_gateway_id
}

output "nat_gateway_public_ip" {
  description = "NAT Gateway public IP"
  value       = module.vpc.nat_gateway_public_ip
}

output "instance_id" {
  description = "EC2 instance ID"
  value       = module.ec2.instance_id
}

output "instance_private_ip" {
  description = "Private IP of the EC2 instance"
  value       = module.ec2.private_ip
}

output "instance_public_ip" {
  description = "Public IP of the EC2 instance (if in public subnet)"
  value       = module.ec2.public_ip
}

output "rds_address" {
  description = "Host-only address of the RDS instance (use as DB_HOST)"
  value       = module.rds.rds_address
}

output "rds_port" {
  description = "Port the RDS instance listens on"
  value       = module.rds.rds_port
}

output "rds_endpoint" {
  description = "Combined host:port endpoint of the RDS instance"
  value       = module.rds.rds_endpoint
}

output "db_name" {
  description = "Name of the initial database"
  value       = module.rds.db_name
}

output "db_username" {
  description = "RDS master username"
  value       = module.rds.db_username
}

output "rds_master_password" {
  description = "Generated master password — retrieve with: terraform output -raw rds_master_password"
  value       = module.rds.rds_master_password
  sensitive   = true
}
