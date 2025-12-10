# Data source to get the hosted zone
data "aws_route53_zone" "main" {
  name         = var.hosted_zone
  private_zone = false
}

# Data source to get the existing ACM certificate
data "aws_acm_certificate" "existing" {
  domain   = data.aws_route53_zone.main.name
  statuses = ["ISSUED"]
}

# API Gateway custom domain
resource "aws_api_gateway_domain_name" "api" {
  domain_name              = "${var.project_name}.${data.aws_route53_zone.main.name}"
  regional_certificate_arn = data.aws_acm_certificate.existing.arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name        = "${var.project_name}-api-domain"
    Environment = var.environment
  }
}

# API Gateway base path mapping
resource "aws_api_gateway_base_path_mapping" "api" {
  api_id      = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.api.stage_name
  domain_name = aws_api_gateway_domain_name.api.domain_name
}

# Route53 A record for the API Gateway custom domain
resource "aws_route53_record" "api" {
  zone_id = data.aws_route53_zone.main.zone_id
  name    = aws_api_gateway_domain_name.api.domain_name
  type    = "A"

  alias {
    name                   = aws_api_gateway_domain_name.api.regional_domain_name
    zone_id                = aws_api_gateway_domain_name.api.regional_zone_id
    evaluate_target_health = false
  }
}
