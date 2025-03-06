# Serverless AWS Infrastructure with Terraform

This project contains Terraform modules to provision a serverless AWS architecture including S3, CloudFront, API Gateway, Lambda functions, SQS, DynamoDB, and IAM roles/policies.

## Architecture Overview

The infrastructure includes:

- **S3 Bucket**: For static content hosting
- **CloudFront Distribution**: CDN for delivering content from S3
- **API Gateway**: HTTP API for serverless backend
- **Lambda Functions**: Serverless compute for API handling and order processing
- **SQS Queue**: Message queue for asynchronous order processing
- **DynamoDB Table**: NoSQL database for order persistence
- **IAM Roles & Policies**: Secure access controls between services

## Order Processing Flow

This architecture implements an order processing system:

1. **User Order Submission**:
   - Users submit order details through the frontend hosted on S3/CloudFront
   - API Gateway routes the request to the API Handler Lambda function

2. **Order Processing**:
   - API Handler Lambda validates the order data
   - Valid orders are sent to SQS for asynchronous processing
   - SQS triggers the Queue Processor Lambda
   - Queue Processor Lambda stores order data in DynamoDB

3. **Data Model**:
   - DynamoDB table uses `orderId` as the primary key
   - Global Secondary Index on `customerId` and `orderDate` for efficient querying

## Module Structure

Each AWS service is implemented as a separate module:

```
.
├── main.tf                  # Main configuration file
├── variables.tf             # Input variables
├── outputs.tf               # Output values
├── provider.tf              # AWS provider configuration
└── modules/
    ├── s3/                  # S3 bucket module
    ├── cloudfront/          # CloudFront distribution module
    ├── api_gateway/         # API Gateway module
    ├── lambda/              # Lambda functions module
    ├── sqs/                 # SQS queue module
    ├── dynamodb/            # Dynamodb module
    └── iam/                 # IAM roles and policies module
```

## Usage

1. Initialize Terraform:
   ```
   terraform init
   ```

2. Review the execution plan:
   ```
   terraform plan
   ```

3. Apply the changes:
   ```
   terraform apply
   ```

4. To destroy the infrastructure:
   ```
   terraform destroy
   ```

## Customization

You can customize the deployment by modifying the variables in `variables.tf` or by passing them at runtime:

```
terraform apply -var="environment=staging" -var="project=my-app"
```

## Outputs

After deployment, you'll receive the following outputs:

- S3 bucket name
- CloudFront distribution domain name and ID
- API Gateway URL
- Lambda function names
- SQS queue URL
- DynamoDB table name and ARN

## Security Considerations

This infrastructure includes:

- Private S3 bucket with CloudFront OAI access
- API Gateway with CORS configuration
- IAM least privilege policies
- SQS with server-side encryption and dead-letter queue
- DynamoDB with server-side encryption and point-in-time recovery
- Lambda functions with appropriate permissions

## Architecture Diagrams

This project includes multiple architecture diagrams:

- `architecture-diagram.md` - High-level conceptual diagram showing service interactions
- `technical-diagram.md` - Detailed technical diagram showing specific AWS resources
- `aws-architecture-diagram.md` - Instructions for creating AWS architecture diagrams with official icons

## Sample Order Payload

The Lambda functions are set up to process order payloads like this:

```json
{
  "orderId": "ORD-12345",
  "customerId": "CUST-6789",
  "orderDate": "2025-03-06T16:30:00Z",
  "items": [
    {
      "productId": "PROD-001",
      "name": "Widget Pro",
      "quantity": 2,
      "price": 19.99
    },
    {
      "productId": "PROD-002",
      "name": "Super Gadget",
      "quantity": 1,
      "price": 49.99
    }
  ],
  "shippingAddress": {
    "street": "123 Main St",
    "city": "Anytown",
    "state": "CA",
    "zipCode": "12345"
  },
  "paymentMethod": "credit_card",
  "totalAmount": 89.97
}
```

## Requirements

- Terraform >= 1.0
- AWS provider ~> 5.0
- AWS CLI configured with appropriate credentials