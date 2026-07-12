resource "aws_route53_zone" "this" {
  name    = var.zone_name
  comment = "Delegated subdomain for ${var.zone_name} — NS records must be added under the parent domain at the registrar."
  tags    = var.tags
}
