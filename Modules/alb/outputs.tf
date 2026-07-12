output "alb_arn" {
  description = "ARN of the Application Load Balancer"
  value       = aws_lb.this.arn
}

output "alb_dns_name" {
  description = "DNS name AWS assigns to the ALB"
  value       = aws_lb.this.dns_name
}

output "security_group_id" {
  description = "Security group ID attached to the ALB — app instances should allow ingress from this SG"
  value       = aws_security_group.alb.id
}

output "target_group_arn" {
  description = "ARN of the target group app instances should register with"
  value       = aws_lb_target_group.app.arn
}
