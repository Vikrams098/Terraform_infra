output "certificate_arn" {
  description = "ARN of the validated ACM certificate, ready to attach to an ALB listener"
  value       = aws_acm_certificate_validation.this.certificate_arn
}
