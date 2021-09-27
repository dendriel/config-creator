resource "aws_sqs_queue" "exporter-queue" {
  name                       = var.sqs.name
  delay_seconds              = 0
  max_message_size           = 2048
  message_retention_seconds  = 86400
  receive_wait_time_seconds  = 20
  visibility_timeout_seconds = 125

  # redrive_policy = jsonencode({
  #   deadLetterTargetArn = aws_sqs_queue.terraform_queue_deadletter.arn
  #   maxReceiveCount     = 4
  # })

  tags = {
    env       = "prod"
    terraform = "true"
  }
}