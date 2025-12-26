variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "hosted_zone" {
  description = "Hosted zone for API Gateway custom domain"
  type        = string
}

variable "tfstate_bucket" {
  description = "The S3 bucket to use for storing state"
  type        = string
}

variable "weather_api_base_url" {
  description = "The Open-Meteo API base URL"
  type        = string
}

variable "prod_key_id" {
  description = "API gateway key for prod"
  type        = string
  sensitive   = true
}

variable "dev_key_id" {
  description = "API gateway key for dev"
  type        = string
  sensitive   = true
}

variable "environment" {
  description = "Map of environments and their configurations"
  type = map(object({
    throttle_rate   = number
    throttle_burst  = number
    quota_limit     = number
    tags            = map(string)
  }))
  default = {
    dev = {
      throttle_rate  = 10
      throttle_burst = 20
      quota_limit    = 1000
      tags = {
        Environment = "dev"
      }
    }
    prod = {
      throttle_rate  = 50
      throttle_burst = 100
      quota_limit    = 10000
      tags = {
        Environment = "prod"
      }
    }
  }
}


