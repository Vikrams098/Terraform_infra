output "vpc_id" {
  value = aws_vpc.myvpc.id
}

output "instance_id" {
  value = aws_instance.Infra_ec2.id
}

output "public_ip" {
  value = aws_instance.Infra_ec2.public_ip
}
