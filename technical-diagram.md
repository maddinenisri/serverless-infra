# Terraform AWS Serverless Infrastructure - Technical Diagram

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                                             │
│                                      AWS Cloud Infrastructure                                               │
│                                                                                                             │
├─────────────────────┬─────────────────────┬─────────────────────┬─────────────────────┬─────────────────────┬─────────────────────┤
│                     │                     │                     │                     │                     │                     │
│   S3 Module         │  CloudFront Module  │  API Gateway Module │   Lambda Module     │    SQS Module       │  DynamoDB Module    │
│                     │                     │                     │                     │                     │                     │
├─────────────────────┼─────────────────────┼─────────────────────┼─────────────────────┼─────────────────────┼─────────────────────┤
│                     │                     │                     │                     │                     │
│ ┌─────────────────┐ │ ┌─────────────────┐ │ ┌─────────────────┐ │ ┌─────────────────┐ │ ┌─────────────────┐ │
│ │ aws_s3_bucket   │ │ │ aws_cloudfront_ │ │ │ aws_apigatewayv2│ │ │ aws_lambda_     │ │ │ aws_sqs_queue   │ │
│ │                 │ │ │ origin_access_  │ │ │ _api            │ │ │ function        │ │ │                 │ │
│ │ - versioning    │ │ │ identity        │ │ │                 │ │ │ (api_handler)   │ │ │ - encryption    │ │
│ │ - encryption    │ │ │                 │ │ │ - HTTP API      │ │ │                 │ │ │ - retention     │ │
│ │ - access block  │ │ └────────┬────────┘ │ │ - CORS config   │ │ └────────┬────────┘ │ │ - timeout       │ │
│ │                 │ │          │          │ │                 │ │          │          │ │                 │ │
│ └────────┬────────┘ │          │          │ └────────┬────────┘ │          │          │ └────────┬────────┘ │
│          │          │          │          │          │          │          │          │          │          │
│          │          │ ┌────────▼────────┐ │ ┌────────▼────────┐ │ ┌────────▼────────┐ │ ┌────────▼────────┐ │
│          │          │ │ aws_s3_bucket_ │ │ │ aws_apigatewayv2│ │ │ aws_lambda_     │ │ │ aws_sqs_queue   │ │
│          │          │ │ policy          │ │ │ _stage          │ │ │ function        │ │ │ (DLQ)           │ │
│          │          │ │                 │ │ │                 │ │ │ (process_queue) │ │ │                 │ │
│          │          │ │ - OAI access    │ │ │ - auto deploy   │ │ │                 │ │ │ - longer        │ │
│          │          │ │                 │ │ │ - logging       │ │ │                 │ │ │   retention     │ │
│          │          │ └────────┬────────┘ │ └────────┬────────┘ │ └────────┬────────┘ │ │                 │ │
│          │          │          │          │          │          │          │          │ └─────────────────┘ │
│          │          │          │          │          │          │          │          │                     │
│          │          │ ┌────────▼────────┐ │ ┌────────▼────────┐ │ ┌────────▼────────┐ │                     │
│          │          │ │ aws_cloudfront_ │ │ │ aws_apigatewayv2│ │ │ aws_lambda_     │ │                     │
│          │          │ │ distribution    │ │ │ _route          │ │ │ event_source_   │ │                     │
│          │          │ │                 │ │ │                 │ │ │ mapping         │ │                     │
│          │          │ │ - s3 origin     │ │ │ - GET /items    │ │ │                 │ │                     │
│          │          │ │ - HTTPS         │ │ │ - GET /items/id │ │ │ - SQS trigger   │ │                     │
│          │          │ │ - caching       │ │ │ - POST /items   │ │ │                 │ │                     │
│          │          │ └─────────────────┘ │ └────────┬────────┘ │ └─────────────────┘ │                     │
│          │          │                     │          │          │                     │                     │
│          │          │                     │ ┌────────▼────────┐ │                     │                     │
│          │          │                     │ │ aws_apigatewayv2│ │                     │                     │
│          │          │                     │ │ _integration    │ │                     │                     │
│          │          │                     │ │                 │ │                     │                     │
│          │          │                     │ │ - Lambda proxy  │ │                     │                     │
│          │          │                     │ │                 │ │                     │                     │
│          │          │                     │ └─────────────────┘ │                     │                     │
│          │          │                     │                     │                     │                     │
└──────────┼──────────┴─────────────────────┴─────────────────────┴─────────────────────┴─────────────────────┼─────────────────────┤
           │                                                                                                  │                     │
           │                                                                                                  │ ┌─────────────────┐ │
           │                                                                                                  │ │ aws_dynamodb_   │ │
           │                                                                                                  │ │ table           │ │
           │                                                                                                  │ │                 │ │
           │                                                                                                  │ │ - hash_key      │ │
           │                                                                                                  │ │ - GSI           │ │
           │                                                                                                  │ │ - encryption    │ │
           │                                                                                                  │ │ - recovery      │ │
           │                                                                                                  │ │                 │ │
           │                                                                                                  │ └─────────────────┘ │
           │                                                                                                  │                     │
└──────────┴──────────────────────────────────────────────────────────────────────────────────────────────────┴─────────────────────┘
           │
           │
┌──────────▼──────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                                             │
│                                             IAM Module                                                      │
│                                                                                                             │
├─────────────────────┬─────────────────────┬─────────────────────┬─────────────────────┬─────────────────────┤
│                     │                     │                     │                     │                     │
│ ┌─────────────────┐ │ ┌─────────────────┐ │ ┌─────────────────┐ │ ┌─────────────────┐ │ ┌─────────────────┐ │
│ │ aws_iam_role    │ │ │ aws_iam_policy  │ │ │ aws_iam_policy  │ │ │ aws_iam_policy  │ │ │ aws_iam_policy  │ │
│ │                 │ │ │ (s3_access)     │ │ │ (sqs_access)    │ │ │ (dynamodb_access)│ │ │ (cloudwatch)    │ │
│ │ - Lambda        │ │ │                 │ │ │                 │ │ │                 │ │ │                 │ │
│ │   execution     │ │ │ - GetObject     │ │ │ - SendMessage   │ │ │ - GetItem       │ │ │ - CreateLog     │ │
│ │   role          │ │ │ - PutObject     │ │ │ - ReceiveMessage│ │ │ - PutItem       │ │ │ - PutLogEvents  │ │
│ │                 │ │ │ - ListBucket    │ │ │ - DeleteMessage │ │ │ - UpdateItem    │ │ │                 │ │
│ │                 │ │ │ - DeleteObject  │ │ │                 │ │ │ - Query         │ │ │                 │ │
│ └─────────────────┘ │ └─────────────────┘ │ └─────────────────┘ │ └─────────────────┘ │ └─────────────────┘ │
│                     │                     │                     │                     │                     │
└─────────────────────┴─────────────────────┴─────────────────────┴─────────────────────┼─────────────────────┤
                                                                                        │                     │
                                                                                        │ ┌─────────────────┐ │
                                                                                        │ │ aws_iam_role_   │ │
                                                                                        │ │ policy_         │ │
                                                                                        │ │ attachment      │ │
                                                                                        │ │                 │ │
                                                                                        │ │ - Attaches      │ │
                                                                                        │ │   policies to    │ │
                                                                                        │ │   roles         │ │
                                                                                        │ │                 │ │
                                                                                        │ └─────────────────┘ │
                                                                                        │                     │
└────────────────────────────────────────────────────────────────────────────────────────┴─────────────────────┘
```

## Module Dependencies and Data Flow

```
┌───────────────┐     ┌───────────────┐
│               │     │               │
│  S3 Module    ├────►│  CloudFront   │
│               │     │    Module     │◄────┐
└───────┬───────┘     └───────────────┘     │
        │                                   │
        │                                   │
        │             ┌───────────────┐     │
        │             │               │     │
        └────────────►│  IAM Module   │◄────┼─────┬───────────────┐     ┌───────────────┐
                      │               │     │     │               │     │               │
                      └───────┬───────┘     │     │  SQS Module   │     │  DynamoDB     │
                              │             │     │               │     │  Module       │
                              │             │     └───────┬───────┘     └───────┬───────┘
                              │             │             │                     │
                              │             │             │                     │
                      ┌───────▼───────┐     │     ┌───────┴───────┐             │
                      │               │     │     │               │             │
                      │ Lambda Module ├─────┼────►│ API Gateway   │             │
                      │               │◄────┼─────┤    Module     │             │
                      └───────┬───────┘     │     └───────────────┘             │
                              │             │                                   │
                              └─────────────┼───────────────────────────────────┘
                                            │
                                            │
                                            │
```

## Resource Relationships

1. **S3 Bucket & CloudFront**:
   - CloudFront distribution uses S3 bucket as primary origin
   - CloudFront OAI provides secure access to S3
   - Default cache behavior serves static content

2. **CloudFront & API Gateway**:
   - CloudFront uses API Gateway as secondary origin
   - Path pattern "/api/v1/*" routes to API Gateway
   - Ordered cache behavior with appropriate forwarded values

2. **Lambda & API Gateway**:
   - API Gateway routes invoke Lambda functions
   - Lambda functions process API requests

3. **Lambda & SQS**:
   - API Handler Lambda sends messages to SQS
   - Queue Processor Lambda is triggered by SQS events

4. **Lambda & DynamoDB**:
   - Queue Processor Lambda stores order data in DynamoDB
   - DynamoDB provides persistent storage with GSI for customer queries

5. **IAM Roles & All Services**:
   - Lambda execution role with policies for:
     - S3 bucket access
     - SQS queue operations
     - DynamoDB table operations
     - CloudWatch logging

6. **Monitoring**:
   - API Gateway stage configured with CloudWatch logging
   - Lambda functions log to CloudWatch
   - SQS configured with dead-letter queue for failed messages
   - DynamoDB configured with point-in-time recovery