terraform {
  required_version = ">= 1.10"
  
  backend "s3" {
    bucket         = var.tfstate_bucket
    key            = "api/terraform.tfstate"
    region         = var.aws_region
    encrypt        = true
  }
  
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
    archive = {
      source  = "hashicorp/archive"
      version = "~> 2.4"
    }
    null = {
      source  = "hashicorp/null"
      version = "~> 3.2"
    }
  }
}

provider "aws" {
  region = var.aws_region

  default_tags {
    tags = {
        Project     = var.project_name
    }
  }
}
