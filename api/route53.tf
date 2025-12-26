# Data source to get the hosted zone
data "aws_route53_zone" "main" {
  name         = var.hosted_zone
  private_zone = false
}

# Data source to get the ACM certificate (checks for wildcard first, then exact domain)
data "aws_acm_certificate" "existing" {
  domain   = "*.${var.hosted_zone}"
  statuses = ["ISSUED"]
  most_recent = true
}

# Route53 A record for the API Gateway custom domain
resource "aws_route53_record" "api" {
  depends_on = [
    aws_api_gateway_domain_name.api
  ]
  zone_id = data.aws_route53_zone.main.zone_id
  name    = aws_api_gateway_domain_name.api.domain_name
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.api.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.api.regional_zone_id
    evaluate_target_health = false
  }
}