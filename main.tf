locals {
  name_prefix = "${var.project}-${var.environment}"
}

# Create S3 bucket first
module "s3" {
  source = "./modules/s3"

  bucket_name = "${local.name_prefix}-storage"
  environment = var.environment
  tags        = var.default_tags
}

# Create SQS queue
module "sqs" {
  source = "./modules/sqs"

  environment = var.environment
  tags        = var.default_tags
  name_prefix = local.name_prefix
}

# Create DynamoDB tables for order persistence
module "dynamodb" {
  source = "./modules/dynamodb"

  environment   = var.environment
  tags          = var.default_tags
  name_prefix   = local.name_prefix
  enable_stream = false # Set to true if you want to enable DynamoDB streams
}

# Create IAM roles and policies
# Note: We're not passing lambda_function_arns to avoid circular dependency
module "iam" {
  source = "./modules/iam"

  environment          = var.environment
  tags                 = var.default_tags
  name_prefix          = local.name_prefix
  s3_bucket_arn        = module.s3.bucket_arn
  sqs_queue_arn        = module.sqs.queue_arn
  dynamodb_table_arn   = module.dynamodb.table_arn
  lambda_function_arns = {} # Empty map to avoid circular dependency
}

# Create Lambda functions
module "lambda" {
  source     = "./modules/lambda"
  depends_on = [module.iam] # Explicit dependency

  environment            = var.environment
  tags                   = var.default_tags
  name_prefix            = local.name_prefix
  sqs_queue_arn          = module.sqs.queue_arn
  sqs_queue_url          = module.sqs.queue_url
  dynamodb_table_name    = module.dynamodb.table_name
  lambda_role_dependency = module.iam.lambda_role_name
}

# Create API Gateway
module "api_gateway" {
  source     = "./modules/api_gateway"
  depends_on = [module.lambda] # Explicit dependency

  environment           = var.environment
  tags                  = var.default_tags
  name_prefix           = local.name_prefix
  lambda_invoke_arns    = module.lambda.invoke_arns
  lambda_function_names = module.lambda.function_names
}

# Create CloudFront distribution
module "cloudfront" {
  source     = "./modules/cloudfront"
  depends_on = [module.s3, module.api_gateway] # Explicit dependency on both S3 and API Gateway

  s3_bucket_id                   = module.s3.bucket_id
  s3_bucket_domain_name          = module.s3.bucket_domain_name
  s3_bucket_regional_domain_name = module.s3.bucket_regional_domain_name

  # Extract domain name from API Gateway URL (remove https:// and path)
  api_gateway_domain_name = replace(replace(module.api_gateway.api_url, "/^https:\\/\\//", ""), "/\\/.*$/", "")
  api_gateway_stage       = module.api_gateway.stage_name

  environment = var.environment
  tags        = var.default_tags
}
