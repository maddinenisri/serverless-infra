resource "aws_sqs_queue" "this" {
  name                       = "${var.name_prefix}-queue"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 345600 # 4 days
  visibility_timeout_seconds = 60
  receive_wait_time_seconds  = 10

  # Enable server-side encryption
  sqs_managed_sse_enabled = true

  # Enable dead-letter queue
  redrive_policy = jsonencode({
    deadLetterTargetArn = aws_sqs_queue.dlq.arn
    maxReceiveCount     = 5
  })

  tags = var.tags
}

resource "aws_sqs_queue" "dlq" {
  name                       = "${var.name_prefix}-dlq"
  delay_seconds              = 0
  max_message_size           = 262144
  message_retention_seconds  = 1209600 # 14 days
  visibility_timeout_seconds = 60
  receive_wait_time_seconds  = 10

  # Enable server-side encryption
  sqs_managed_sse_enabled = true

  tags = var.tags
}
