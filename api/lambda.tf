# Install dependencies into a separate directory for the layer
resource "null_resource" "install_dependencies" {
  triggers = {
    requirements = filemd5("${path.module}/requirements.txt")
  }

  provisioner "local-exec" {
    command = "pip install -r requirements.txt --platform manylinux2014_x86_64 --only-binary=:all: -t lambda_layer/python/lib/python3.11/site-packages --upgrade"
    working_dir = path.module
  }
}

# Archive the Lambda layer (dependencies)
data "archive_file" "layer_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_layer"
  output_path = "${path.module}/lambda_layer.zip"

  depends_on = [null_resource.install_dependencies]
}

# Archive the Lambda function code (source only)
data "archive_file" "lambda_zip" {
  type        = "zip"
  source_dir  = "${path.module}/lambda_package"
  output_path = "${path.module}/lambda_function.zip"
}

# IAM role for Lambda
resource "aws_iam_role" "lambda_role" {
  name = "${var.project_name}-lambda-role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "lambda.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Name        = "${var.project_name}-lambda-role"
  }
}

# Attach basic execution policy to Lambda role
resource "aws_iam_role_policy_attachment" "lambda_basic" {
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
  role       = aws_iam_role.lambda_role.name
}

# Lambda Layer for dependencies
resource "aws_lambda_layer_version" "dependencies" {
  filename            = data.archive_file.layer_zip.output_path
  layer_name          = "${var.project_name}-dependencies"
  compatible_runtimes = ["python3.12"]
  source_code_hash    = data.archive_file.layer_zip.output_base64sha256

  description = "Dependencies layer for ${var.project_name} (pydantic, requests)"
}

# Lambda function
resource "aws_lambda_function" "api_lambda" {
  depends_on = [
    aws_iam_role_policy_attachment.lambda_basic
  ]

  filename         = data.archive_file.lambda_zip.output_path
  function_name    = "${var.project_name}-function"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_handler.handler"
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  runtime         = "python3.12"
  timeout         = 29
  memory_size     = 512
  
  layers = [aws_lambda_layer_version.dependencies.arn]

  environment {
    variables = {
      WEATHER_API_BASE_URL = var.weather_api_base_url
    }
  }

  tags = {
    Name        = "${var.project_name}-function"
  }

  
}
