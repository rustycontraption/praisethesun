variable "aws_region" {
  description = "AWS region to deploy resources"
  type        = string
}

variable "project_name" {
  description = "Project name used for resource naming"
  type        = string
}

variable "environment" {
  description = "Environment name (dev, staging, prod)"
  type        = string
  default     = "dev"
}

variable "hosted_zone" {
  description = "Hosted zone for API Gateway custom domain"
  type        = string
}

variable "tfstate_bucket" {
  description = "The S3 bucket to use for storing state"
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

