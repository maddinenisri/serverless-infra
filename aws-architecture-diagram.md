# AWS Architecture Diagram for Serverless Order Processing System

## Architecture Overview

Our serverless architecture processes order details from users through a web frontend hosted on S3/CloudFront, with API Gateway and Lambda functions handling the business logic, SQS for asynchronous processing, and DynamoDB for order persistence.

## Creating a JPEG Diagram with AWS Icons

To create a professional AWS architecture diagram with official AWS icons in JPEG format, follow these steps:

1. **Use AWS Architecture Center**:
   - Visit [AWS Architecture Center](https://aws.amazon.com/architecture/icons/)
   - Download the official AWS Architecture Icons

2. **Option 1: AWS Application Composer**:
   - Visit [AWS Application Composer](https://console.aws.amazon.com/applicationcomposer)
   - Create your architecture visually
   - Export as an image

3. **Option 2: Use Diagram Tools**:
   - [Lucidchart](https://www.lucidchart.com/) (has AWS shape libraries)
   - [draw.io](https://draw.io/) (has AWS shape libraries)
   - Microsoft Visio with AWS stencils

## Architecture Components and Flow

Below is the architecture for our serverless order processing system:

```
┌─────────────────────────────────────────────────────────────────────────────────────────────────┐
│                                                                                                 │
│                                         AWS Cloud                                               │
│                                                                                                 │
├─────────────────────────────────────────────────────────────────────────────────────────────────┤
│                                                                                                 │
│                                                                                                 │
│    ┌───────────┐      ┌───────────┐      ┌───────────┐      ┌───────────┐      ┌───────────┐    │
│    │           │      │           │      │           │      │           │      │           │    │
│    │   Users   │─────►│ CloudFront│─────►│  S3 Bucket│      │ API Gateway│─────►│  Lambda   │    │
│    │           │      │           │      │           │      │           │      │(API Handler)   │
│    └───────────┘      └───────────┘      └───────────┘      └───────────┘      └───────┬───┘    │
│                                                                                        │        │
│                                                                                        │        │
│                                                                                        │        │
│                                                                                        ▼        │
│                                                                               ┌───────────┐     │
│                                                                               │           │     │
│                                                                               │    SQS    │     │
│                                                                               │   Queue   │     │
│                                                                               │           │     │
│                                                                               └───────┬───┘     │
│                                                                                       │         │
│                                                                                       │         │
│                                                                                       │         │
│                                                                                       ▼         │
│                                                                               ┌───────────┐     │
│                                                                               │           │     │
│                                                                               │  Lambda   │     │
│                                                                               │(Processor)│     │
│                                                                               │           │     │
│                                                                               └───────┬───┘     │
│                                                                                       │         │
│                                                                                       │         │
│                                                                                       │         │
│                                                                                       ▼         │
│                                                                               ┌───────────┐     │
│                                                                               │           │     │
│                                                                               │ DynamoDB  │     │
│                                                                               │  Table    │     │
│                                                                               │           │     │
│                                                                               └───────────┘     │
│                                                                                                 │
│                                                                                                 │
│                     ┌───────────────────────────────────────────────────────┐                   │
│                     │                                                       │                   │
│                     │                  IAM Roles & Policies                 │                   │
│                     │                                                       │                   │
│                     └───────────────────────────────────────────────────────┘                   │
│                                                                                                 │
└─────────────────────────────────────────────────────────────────────────────────────────────────┘
```

## Data Flow

1. **User Order Submission**:
   - User submits order details via web frontend hosted on S3/CloudFront
   - Web frontend makes API call to API Gateway endpoint

2. **API Processing**:
   - API Gateway routes request to API Handler Lambda function
   - Lambda validates order data
   - Lambda sends order to SQS queue for asynchronous processing
   - Lambda returns immediate acknowledgment to user

3. **Order Persistence**:
   - SQS queue triggers Queue Processor Lambda function
   - Queue Processor Lambda saves order data to DynamoDB
   - Queue Processor updates order status in DynamoDB

4. **Security & Access Control**:
   - IAM roles and policies control permissions between services
   - S3 bucket is private, accessed via CloudFront
   - Lambda functions have least-privilege permissions

## AWS Services Used

- **Amazon S3**: Hosts static web content
- **Amazon CloudFront**: Content delivery network
- **Amazon API Gateway**: RESTful API endpoints
- **AWS Lambda**: Serverless compute functions
- **Amazon SQS**: Message queuing service
- **Amazon DynamoDB**: NoSQL database for order storage
- **AWS IAM**: Identity and access management

## Sample Order Payload

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