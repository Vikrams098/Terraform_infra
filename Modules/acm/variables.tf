variable "domain_name" {
  description = "Primary domain name to issue the certificate for"
  type        = string
}

variable "subject_alternative_names" {
  description = "Additional domain names to cover (e.g. wildcard for future subdomains)"
  type        = list(string)
  default     = []
}

variable "route53_zone_id" {
  description = "Route 53 hosted zone ID used to create the DNS validation records"
  type        = string
}

variable "tags" {
  description = "Common tags applied to every resource"
  type        = map(string)
  default     = {}
}
