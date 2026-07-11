output "vpc_id" {
  description = "ID of the VPC"
  value       = aws_vpc.Kv's_vpc.id
}

output "vpc_cidr" {
  description = "CIDR block of the VPC"
  value       = aws_vpc.Kv's_vpc.cidr_block
}

output "internet_gateway_id" {
  description = "ID of the Internet Gateway"
  value       = aws_internet_gateway.Kv's_igw.id
}

output "public_subnet_ids" {
  description = "IDs of the public subnets"
  value       = aws_subnet.Kv's_public[*].id
}

output "private_subnet_ids" {
  description = "IDs of the private subnets"
  value       = aws_subnet.Kv's_private[*].id
}

output "nat_gateway_id" {
  description = "ID of the NAT Gateway (empty if disabled)"
  value       = var.enable_nat_gateway ? aws_nat_gateway.Kv's_nat[0].id : null
}

output "nat_gateway_public_ip" {
  description = "Public IP of the NAT Gateway EIP (empty if disabled)"
  value       = var.enable_nat_gateway ? aws_eip.Kv's_nat[0].public_ip : null
}

output "public_route_table_id" {
  description = "ID of the public route table"
  value       = aws_route_table.Kv's_public_rt.id
}

output "private_route_table_id" {
  description = "ID of the private route table"
  value       = aws_route_table.Kv's_private_rt.id
}
