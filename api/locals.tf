locals {
  # Map stage names to their API key IDs from environment variables
  stage_api_keys = {
    dev  = var.dev_key_id
    prod = var.prod_key_id
  }

  # Merge stage configurations with their corresponding API keys
  environment = {
    for env, config in var.environment : env => merge(config, {
      api_key_id = local.stage_api_keys[env]
    })
  }
}