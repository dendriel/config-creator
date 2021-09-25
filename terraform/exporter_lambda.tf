resource "aws_lambda_function" "exporter" {
  filename      = "config-creator-exporter.zip"
  function_name = "config-creator-exporter"
  role          = aws_iam_role.exporter-lambda.arn
  handler       = "index.handler"

  source_code_hash = data.archive_file.lambda-exporter-code.output_base64sha256

  runtime = "nodejs14.x"

  depends_on = [
    data.archive_file.lambda-exporter-code
  ]

  environment {
    variables = {
      foo = "bar"
    }
  }

  tags = {
    env = "prod"
    terraform = "true"
  }
}

resource "aws_lambda_event_source_mapping" "exporter-lambda-trigger-event" {
  event_source_arn = aws_sqs_queue.exporter-queue.arn
  enabled          = true
  function_name    = aws_lambda_function.exporter.arn
  batch_size       = 1
}

resource "aws_iam_role" "exporter-lambda" {
  name = "config-creator-exporter-lambda"

  assume_role_policy = <<EOF
{
  "Version": "2012-10-17",
  "Statement": [
    {
      "Action": "sts:AssumeRole",
      "Principal": {
        "Service": "lambda.amazonaws.com"
      },
      "Effect": "Allow",
      "Sid": ""
    }
  ]
}
EOF
}

resource "aws_iam_role_policy_attachment" "exporter_basic_role_attachment" {
  role       = aws_iam_role.exporter-lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaBasicExecutionRole"
}

resource "aws_iam_role_policy_attachment" "exporter_sqs_role_attachement" {
  role       = aws_iam_role.exporter-lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaSQSQueueExecutionRole"
}

resource "aws_cloudwatch_log_group" "exporter-lambda" {
  name = "/aws/lambda/${aws_lambda_function.exporter.function_name}"

  retention_in_days = 30
}

data "archive_file" "lambda-exporter-code" {
  type = "zip"

  source_dir  = "${path.module}/exporter"
  output_path = "${path.module}/config-creator-exporter.zip"
}