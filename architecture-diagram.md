# Serverless AWS Architecture Diagram

```
                                                            ┌───────────────────┐
                                                            │                   │
                                                            │   AWS CloudWatch  │
                                                            │                   │
                                                            └─────────┬─────────┘
                                                                      │
                                                                      │ Logs
                                                                      │
┌─────────────────┐          ┌─────────────────┐          ┌───────────▼─────────┐          ┌─────────────────┐
│                 │          │                 │          │                     │          │                 │
│     Users       ├─────────►│   CloudFront    ├─────────►│      S3 Bucket     │          │  API Gateway    │
│                 │          │  Distribution   │          │   (Static Content) │          │   (HTTP API)    │
└────────┬────────┘          └─────────────────┘          └─────────────────────┘          └────────┬────────┘
         │                                                                                          │
         │                                                                                          │ Invoke
         │                                                                                          │
         │                                                                                          ▼
         │                                                                             ┌─────────────────────┐
         │                                                                             │                     │
         │                                                                             │   Lambda Function   │
         │                                                                             │   (API Handler)     │
         │                                                                             │                     │
         │                                                                             └─────────┬───────────┘
         │                                                                                       │
         │                                                                                       │ Send
         │                                                                                       │ Message
         │                                                                                       ▼
         │                                                                             ┌─────────────────────┐
         │                                                                             │                     │
         │                                                                             │     SQS Queue       │
         │                                                                             │                     │
         │                                                                             └─────────┬───────────┘
         │                                                                                       │
         │                                                                                       │ Trigger
         │                                                                                       │
         │                                                                                       ▼
         │                                                                             ┌─────────────────────┐
         │                                                                             │                     │
         │                                                                             │   Lambda Function   │
         │                                                                             │  (Queue Processor)  │
         │                                                                             │                     │
         │                                                                             └─────────┬───────────┘
         │                                                                                       │
         │                                                                                       │ Store/Retrieve
         │                                                                                       │
         │                                                                             ┌─────────▼───────────┐
         │                                                                             │                     │
         │                                                                             │    DynamoDB Table   │
         │                                                                             │   (Order Storage)   │
         │                                                                             │                     │
         │                                                                             └─────────────────────┘

                                      ┌─────────────────────────────────────┐
                                      │                                     │
                                      │      IAM Roles and Policies         │
                                      │  (Secure access between services)   │
                                      │                                     │
                                      └─────────────────────────────────────┘
```

## Component Interactions

1. **User Flow:**
   - Users access the application through CloudFront distribution
   - Static content is served from S3 bucket
   - API requests are routed to API Gateway

2. **API Processing:**
   - API Gateway receives HTTP requests
   - Routes requests to the API Handler Lambda function
   - Lambda processes requests and returns responses

3. **Asynchronous Processing:**
   - API Handler Lambda sends messages to SQS queue for background processing
   - Queue Processor Lambda is triggered by messages in SQS
   - Order data is persisted in DynamoDB

4. **Security:**
   - IAM roles and policies control access between services
   - Lambda roles have specific permissions for S3, SQS, DynamoDB, and CloudWatch
   - S3 bucket is private, accessed via CloudFront using Origin Access Identity
   - DynamoDB table has server-side encryption enabled

5. **Monitoring:**
   - All services log to CloudWatch
   - Lambda functions, API Gateway, and SQS metrics available in CloudWatch

## Key Benefits

- **Scalability:** Services scale automatically based on demand
- **Cost-Efficient:** Pay only for what you use
- **Maintainable:** Modular architecture allows independent updates
- **Secure:** Least privilege IAM policies and private resources
- **Resilient:** SQS includes dead-letter queue for failed message handling