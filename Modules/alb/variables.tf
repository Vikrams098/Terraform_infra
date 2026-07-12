variable "name" {
  description = "Base name used for the ALB and dependent resources"
  type        = string
}

variable "vpc_id" {
  description = "VPC ID to create the ALB and target group in"
  type        = string
}

variable "public_subnet_ids" {
  description = "Public subnet IDs the ALB is placed in (must span at least 2 AZs)"
  type        = list(string)
}

variable "app_port" {
  description = "Port the application listens on inside each instance"
  type        = number
  default     = 3000
}

variable "health_check_path" {
  description = "HTTP path the target group health check requests"
  type        = string
  default     = "/api/health"
}

variable "certificate_arn" {
  description = "ACM certificate ARN for the HTTPS listener"
  type        = string
}

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID to create the app's alias record in"
  type        = string
}

variable "domain_name" {
  description = "Fully-qualified domain name the ALB should answer on (e.g. app.awsprojects.cloud)"
  type        = string
}

variable "tags" {
  description = "Common tags applied to every resource"
  type        = map(string)
  default     = {}
}
