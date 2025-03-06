locals {
  lambda_functions = {
    api_handler = {
      description = "API Handler Lambda Function for Order Processing"
      handler     = "index.handler"
      runtime     = "nodejs18.x"
      memory_size = 128
      timeout     = 30
    }
    process_queue = {
      description = "SQS Queue Processor Lambda Function for Order Persistence"
      handler     = "processor.handler"
      runtime     = "nodejs18.x"
      memory_size = 256
      timeout     = 60
    }
  }
}

# First, create the dummy Lambda files
resource "local_file" "dummy_lambda" {
  filename = "${path.module}/dummy_lambda/index.js"
  content  = <<-EOF
    // API Handler Lambda Function
    const AWS = require('aws-sdk');
    const sqs = new AWS.SQS();

    exports.handler = async (event) => {
      console.log('Received API event:', JSON.stringify(event, null, 2));
      
      try {
        // Parse the incoming HTTP request
        const body = event.body ? JSON.parse(event.body) : {};
        
        // Validate that this is an order
        if (!body.orderId || !body.customerId || !body.items) {
          return {
            statusCode: 400,
            body: JSON.stringify({
              message: 'Invalid order data. Required fields: orderId, customerId, items'
            }),
          };
        }
        
        // Add timestamp if not provided
        const orderData = {
          ...body,
          orderDate: body.orderDate || new Date().toISOString(),
          status: 'RECEIVED'
        };
        
        // Send order to SQS for async processing
        await sqs.sendMessage({
          QueueUrl: process.env.SQS_QUEUE_URL,
          MessageBody: JSON.stringify(orderData),
          MessageAttributes: {
            OrderId: {
              DataType: 'String',
              StringValue: orderData.orderId
            }
          }
        }).promise();
        
        return {
          statusCode: 202,
          body: JSON.stringify({
            message: 'Order received and queued for processing',
            orderId: orderData.orderId
          }),
        };
      } catch (error) {
        console.error('Error processing order:', error);
        return {
          statusCode: 500,
          body: JSON.stringify({ message: 'Error processing order' }),
        };
      }
    };
  EOF
}

resource "local_file" "dummy_processor" {
  filename = "${path.module}/dummy_lambda/processor.js"
  content  = <<-EOF
    // Queue Processor Lambda Function
    const AWS = require('aws-sdk');
    const dynamodb = new AWS.DynamoDB.DocumentClient();

    exports.handler = async (event) => {
      console.log('Processing SQS messages:', JSON.stringify(event, null, 2));
      
      // Process each message from SQS
      const processPromises = event.Records.map(async (record) => {
        try {
          // Parse the order data from the message
          const orderData = JSON.parse(record.body);
          console.log('Processing order:', orderData.orderId);
          
          // Update order status
          orderData.status = 'PROCESSED';
          orderData.processedAt = new Date().toISOString();
          
          // Store in DynamoDB
          await dynamodb.put({
            TableName: process.env.DYNAMODB_TABLE,
            Item: orderData
          }).promise();
          
          console.log('Order saved to DynamoDB:', orderData.orderId);
          return { success: true, orderId: orderData.orderId };
        } catch (error) {
          console.error('Error processing order:', error);
          return { success: false, error: error.message };
        }
      });
      
      // Wait for all processing to complete
      return Promise.all(processPromises);
    };
  EOF
}

# Then, create the zip archive
data "archive_file" "dummy_lambda" {
  type        = "zip"
  output_path = "${path.module}/dummy_lambda.zip"
  source_dir  = "${path.module}/dummy_lambda"
  depends_on  = [local_file.dummy_lambda, local_file.dummy_processor]
}

data "aws_iam_role" "lambda" {
  name       = "${var.name_prefix}-lambda-role"
  depends_on = [var.lambda_role_dependency]
}

# Finally, create the Lambda functions referencing the zip file
resource "aws_lambda_function" "this" {
  for_each = local.lambda_functions

  function_name = "${var.name_prefix}-${each.key}"
  description   = each.value.description
  handler       = each.value.handler
  runtime       = each.value.runtime
  memory_size   = each.value.memory_size
  timeout       = each.value.timeout
  role          = data.aws_iam_role.lambda.arn

  filename         = data.archive_file.dummy_lambda.output_path
  source_code_hash = data.archive_file.dummy_lambda.output_base64sha256

  environment {
    variables = {
      SQS_QUEUE_URL  = each.key == "api_handler" ? var.sqs_queue_url : null
      DYNAMODB_TABLE = each.key == "process_queue" ? var.dynamodb_table_name : null
    }
  }

  tags = var.tags

  depends_on = [data.archive_file.dummy_lambda]

  lifecycle {
    ignore_changes = [
      filename,
      source_code_hash,
    ]
  }
}

resource "aws_lambda_event_source_mapping" "sqs" {
  event_source_arn = var.sqs_queue_arn
  function_name    = aws_lambda_function.this["process_queue"].function_name
  batch_size       = 10
  enabled          = true
}
