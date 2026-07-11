output "rds_address" {
  description = "Host-only address of the RDS instance (use as DB_HOST)"
  value       = aws_db_instance.kvs_db.address
}

output "rds_port" {
  description = "Port the RDS instance listens on"
  value       = aws_db_instance.kvs_db.port
}

output "rds_endpoint" {
  description = "Combined host:port endpoint of the RDS instance"
  value       = aws_db_instance.kvs_db.endpoint
}

output "rds_master_password" {
  description = "Generated master password — retrieve with: terraform output -raw rds_master_password"
  value       = random_password.master.result
  sensitive   = true
}

output "db_name" {
  description = "Name of the initial database"
  value       = aws_db_instance.kvs_db.db_name
}

output "db_username" {
  description = "Master username"
  value       = aws_db_instance.kvs_db.username
}

output "rds_security_group_id" {
  description = "Security group ID attached to the RDS instance"
  value       = aws_security_group.kvs_sg.id
}
