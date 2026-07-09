output "instance_id" {
  description = "ID of the EC2 instance"
  value       = aws_instance.Sample_EC2.id
}

output "private_ip" {
  description = "Private IP address of the instance"
  value       = aws_instance.Sample_EC2.private_ip
}

output "public_ip" {
  description = "Public IP address (non-empty only for instances in a public subnet)"
  value       = aws_instance.Sample_EC2.public_ip
}

output "security_group_id" {
  description = "ID of the instance security group"
  value       = aws_security_group.infra_SG.id
}
