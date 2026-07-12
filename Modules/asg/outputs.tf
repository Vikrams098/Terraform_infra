output "security_group_id" {
  description = "Security group ID attached to app instances"
  value       = aws_security_group.app.id
}

output "autoscaling_group_name" {
  description = "Name of the Auto Scaling Group — used by the deploy workflow to resolve current instance IDs"
  value       = aws_autoscaling_group.app.name
}
