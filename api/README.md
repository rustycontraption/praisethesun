# Praise the Sun API - AWS Lambda Deployment

This project contains a sun location finder API that has been adapted for AWS Lambda deployment using OpenTofu (Terraform).

## Architecture

- **AWS Lambda**: Runs the sun location API with a custom Lambda handler
- **Lambda Layer**: Contains Python dependencies (pydantic, requests) - separate from source code
- **API Gateway**: Provides HTTP GET endpoint at `/search` and routes requests to Lambda
- **CloudWatch Logs**: Stores Lambda execution logs

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
├── main.tf                          # Main OpenTofu configuration
├── variables.tf                     # Input variables
├── outputs.tf                       # Output values
├── .gitignore                       # Git ignore file
└── README.md                        # This file
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

### 4. Get API Endpoint

After successful deployment, OpenTofu will output the API Gateway URL:

```bash
tofu output api_gateway_url
```

## API Endpoint

### Get Sun Locations
```
GET /search?start_point_lat={lat}&start_point_lng={lng}&radiusKilometers={radius}
```

Parameters:
- `start_point_lat`: Latitude (-90 to 90)
- `start_point_lng`: Longitude (-180 to 180)
- `radiusKilometers`: Search radius in kilometers (0 to 1000)

Returns:
- Array of coordinates with clear weather (weather_code = 0)
- Each coordinate has `lat` and `lng` properties

Example:
```bash
curl "https://your-api-id.execute-api.us-east-1.amazonaws.com/dev/search?start_point_lat=40.7128&start_point_lng=-74.0060&radiusKilometers=50"
```

## Required Configuration Variables

### Environment Vars
`weather_api_base_url`: Weather API base URL.  Required by the script that retrieves weather data.

### OpenTofu
You can configure the deployment by modifying `variables.tf`, passing variables, or setting environment variables (recommended):

```bash
tofu apply -var="aws_region=us-west-2" -var="environment=prod"
```

```bash
export TF_VAR_aws_region=us-west-2
```

Available variables:
- `aws_region`: AWS region 
- `project_name`: Project name prefix
- `environment`: Environment name (default: dev)
- `hosted_zone`: AWS hosted zone for API endpoint
- `tfstate_bucket`: AWS S3 bucket to store tfstate in

## Monitoring

View Lambda logs in CloudWatch:

```bash
aws logs tail /aws/lambda/${lambda_function_name} --follow
```

## Making Changes

### Update Source Code
Just modify files in `lambda_package/` and run `tofu apply`. The layer won't be rebuilt.

### Update Dependencies
1. Modify `requirements.txt`
2. Run `tofu apply`
3. The layer will automatically rebuild when requirements.txt changes

## Cleanup

To remove all AWS resources:

```bash
tofu destroy
```

## Local Development

To test the Lambda handler locally, you can create a test script:

```python
# test_lambda.py
from lambda_handler import handler

event = {
    'queryStringParameters': {
        'start_point_lat': '40.7128',
        'start_point_lng': '-74.0060',
        'radiusKilometers': '50'
    }
}

result = handler(event, None)
print(result)
```
