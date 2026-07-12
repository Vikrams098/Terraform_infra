variable "zone_name" {
  description = "Fully-qualified subdomain to host in Route 53 (e.g. app.awsprojects.cloud)"
  type        = string
}

variable "tags" {
  description = "Common tags applied to every resource"
  type        = map(string)
  default     = {}
}
