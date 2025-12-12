# Praise the Sun API - AWS Deployment

This project contains a sun location finder API that has been adapted for AWS Lambda deployment using OpenTofu (Terraform).

## Architecture

- **AWS Lambda**: Runs the sun location API with a custom Lambda handler
- **API Gateway**: Provides HTTP GET endpoint at `/search` with API key authentication and throttling
- **Route53**: Custom domain configuration with ACM certificate for HTTPS
- **CloudWatch Logs**: Stores Lambda execution logs
- **S3 Backend**: Terraform state stored in S3 for remote state management

## Prerequisites

1. **OpenTofu** (or Terraform) installed
2. **AWS CLI** configured with appropriate credentials
3. **Python 3.11** installed
4. **pip** for Python package management

## Project Structure

```
.
├── lambda_package/
│   ├── calculate_sun_location.py    # Sun location calculation logic
│   └── lambda_handler.py            # Custom Lambda handler for API Gateway
├── requirements.txt                 # Python dependencies
├── main.tf                          # Main Terraform configuration with S3 backend
├── lambda.tf                        # Lambda function and layer resources
├── apigateway.tf                    # API Gateway configuration with API key auth
├── route53.tf                       # Route53 and custom domain setup
├── locals.tf                        # Local var adding API key ID env vars to environment variable map
├── variables.tf                     # Input variables
├── outputs.tf                       # Output values
.
```

## Deployment Steps

### 1. Initialize OpenTofu

```bash
tofu init
```

### 2. Review the Deployment Plan

```bash
tofu plan
```

### 3. Deploy to AWS

```bash
tofu apply
```

When prompted, type `yes` to confirm the deployment.

**Note**: Dependencies are automatically installed into a Lambda Layer during deployment. The `null_resource` in `lambda.tf` runs `pip install` and packages dependencies separately from your source code.

## API Endpoint
After successful deployment, OpenTofu will output the API Gateway URL:

```bash
tofu output api_gateway_url
```

### Get Sun Locations
```
GET /search?start_point_lat={lat}&start_point_lng={lng}&radiusKilometers={radius}
```

## Usage
Headers:
-`x-api-key` 

Parameters:
- `start_point_lat`: Latitude (-90 to 90)
- `start_point_lng`: Longitude (-180 to 180)
- `radiusKilometers`: Search radius in kilometers (0 to 1000)

Returns:
- Array of latitude/longitude coordinates with clear weather (Open-Meteo weather_code = 0)

Example:
```bash
curl -H "x-api-key: YOUR_API_KEY" "https://api.yourdomain.com/search?start_point_lat=40.7128&start_point_lng=-74.0060&radiusKilometers=50"
```

## Required Configuration Variables

You can configure the TF deployment by setting environment variables (recommended) or passing variables via command line:

**Environment variables:**
```bash
export TF_VAR_aws_region="us-east-1"
export TF_VAR_project_name="praisethesun"
```

**Command line:**
```bash
tofy apply -var="aws_region=us-east-1" -var="project_name=praisethesun"
```

**Required TF variables:**
- `aws_region`: AWS region for deployment
- `project_name`: Project name prefix for resource naming
- `hosted_zone`: Route53 hosted zone for custom domain (e.g., "example.com")
- `tfstate_bucket`: S3 bucket name for storing Terraform state
- `dev_key_id`: API Gateway API key ID for development environment (sensitive)
- `prod_key_id`: API Gateway API key ID for production environment (sensitive)
- `weather_api_base_url`: The Open-Meteo API base URL

## Monitoring

View Lambda logs in CloudWatch console, or via aws-cli:

```bash
aws logs tail /aws/lambda/$(tofu output -raw lambda_function_name) --follow
```

## Making Changes to the API

### Update API Source Code
Just modify files in `lambda_package/` and run `tofu apply`.

### Update Dependencies
1. Modify `requirements.txt`
2. Run `tofu apply`
3. The layer will automatically rebuild when requirements.txt changes

## Cleanup

To remove all AWS resources:

```bash
tofu destroy
```

**Note**: This will not delete the S3 bucket containing the Terraform state file.

