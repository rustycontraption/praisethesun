# API Gateway REST API
resource "aws_api_gateway_rest_api" "api" {
  name        = "${var.project_name}-api"
  description = "API Gateway for ${var.project_name}"

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name        = "${var.project_name}-api"
    Environment = var.environment
  }
}

# API Gateway resource for /search
resource "aws_api_gateway_resource" "search" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  parent_id   = aws_api_gateway_rest_api.api.root_resource_id
  path_part   = "search"
}

# API Gateway method for /search
resource "aws_api_gateway_method" "search_get" {
  rest_api_id      = aws_api_gateway_rest_api.api.id
  resource_id      = aws_api_gateway_resource.search.id
  http_method      = "GET"
  authorization    = "NONE"
  api_key_required = true
}

# API Gateway method settings for /search
resource "aws_api_gateway_method_settings" "search_throttle" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.api.stage_name
  method_path = "${aws_api_gateway_resource.search.path_part}/GET"

  settings {
    throttling_rate_limit  = 50    
    throttling_burst_limit = 100  
    logging_level          = "ERROR"
    metrics_enabled        = true
  }
}

# API Gateway integration for /search
resource "aws_api_gateway_integration" "search_lambda" {
  rest_api_id = aws_api_gateway_rest_api.api.id
  resource_id = aws_api_gateway_method.search_get.resource_id
  http_method = aws_api_gateway_method.search_get.http_method

  integration_http_method = "POST"
  type                    = "AWS_PROXY"
  uri                     = aws_lambda_function.api_lambda.invoke_arn
}

# API Gateway deployment
resource "aws_api_gateway_deployment" "api" {
  depends_on = [
    aws_api_gateway_integration.search_lambda,
  ]

  rest_api_id = aws_api_gateway_rest_api.api.id

  triggers = {
    redeployment = sha1(jsonencode([
      aws_api_gateway_resource.search.id,
      aws_api_gateway_method.search_get.id,
      aws_api_gateway_integration.search_lambda.id,
    ]))
  }

  lifecycle {
    create_before_destroy = true
  }
}

# IAM role for API Gateway CloudWatch Logs
resource "aws_iam_role" "api_gateway_cloudwatch" {
  name = "${var.project_name}-api-gateway-cloudwatch-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "apigateway.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-api-gateway-cloudwatch-role"
    Environment = var.environment
  }
}

# Attach AWS managed policy for CloudWatch Logs
resource "aws_iam_role_policy_attachment" "api_gateway_cloudwatch" {
  role       = aws_iam_role.api_gateway_cloudwatch.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AmazonAPIGatewayPushToCloudWatchLogs"
}

# API Gateway account settings for CloudWatch Logs
resource "aws_api_gateway_account" "api" {
  cloudwatch_role_arn = aws_iam_role.api_gateway_cloudwatch.arn
}

# Lambda permission for API Gateway
resource "aws_lambda_permission" "api_gateway" {
  statement_id  = "AllowAPIGatewayInvoke"
  action        = "lambda:InvokeFunction"
  function_name = aws_lambda_function.api_lambda.function_name
  principal     = "apigateway.amazonaws.com"
  source_arn    = "${aws_api_gateway_rest_api.api.execution_arn}/*/*"
}

# API Gateway stage
resource "aws_api_gateway_stage" "api" {
  depends_on    = [ 
    aws_iam_role_policy_attachment.api_gateway_cloudwatch 
    ]
  deployment_id = aws_api_gateway_deployment.api.id
  rest_api_id   = aws_api_gateway_rest_api.api.id
  stage_name    = var.environment

  tags = {
    Name        = "${var.project_name}-${var.environment}-stage"
    Environment = var.environment
  }
}

# API Gateway usage plan
resource "aws_api_gateway_usage_plan" "api_usage_plan" {
  depends_on = [
    aws_api_gateway_stage.api
  ]
  name        = "${var.project_name}-usage-plan"
  description = "Usage plan for ${var.project_name} API"

  api_stages {
    api_id = aws_api_gateway_rest_api.api.id
    stage  = aws_api_gateway_stage.api.stage_name
  }

  throttle_settings {
    rate_limit  = 50
    burst_limit = 100
  }

  quota_settings {
    limit  = var.environment == "prod" ? 10000 : 1000
    period = "DAY"
  }

  tags = {
    Name        = "${var.project_name}-usage-plan"
    Environment = var.environment
  }
}

data "aws_api_gateway_api_key" "project_key" {
  id = var.environment == "prod" ? var.prod_key_id : var.dev_key_id
}

# Associate API keys with usage plan
resource "aws_api_gateway_usage_plan_key" "api_keys" {
  key_id        = data.aws_api_gateway_api_key.project_key.id
  key_type      = "API_KEY"
  usage_plan_id = aws_api_gateway_usage_plan.api_usage_plan.id
}

# API Gateway custom domain
resource "aws_api_gateway_domain_name" "api" {
  domain_name              = "${var.project_name}.${var.hosted_zone}"
  regional_certificate_arn = data.aws_acm_certificate.existing.arn

  endpoint_configuration {
    types = ["REGIONAL"]
  }

  tags = {
    Name        = "${var.project_name}-api-domain"
    Environment = var.environment
  }
}

# Base path mapping to connect domain to API Gateway stage
resource "aws_api_gateway_base_path_mapping" "api" {
  api_id      = aws_api_gateway_rest_api.api.id
  stage_name  = aws_api_gateway_stage.api.stage_name
  domain_name = aws_api_gateway_domain_name.api.domain_name
}


