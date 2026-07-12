output "zone_id" {
  description = "Route 53 hosted zone ID"
  value       = aws_route53_zone.this.zone_id
}

output "name_servers" {
  description = "Name servers for this zone — add these as an NS record for the subdomain at your registrar"
  value       = aws_route53_zone.this.name_servers
}
