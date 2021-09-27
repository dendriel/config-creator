resource "aws_lambda_function" "exporter" {
  filename      = "config-creator-exporter.zip"
  function_name = "config-creator-exporter"
  role          = aws_iam_role.exporter-lambda.arn
  handler       = "index.handler"
  timeout       = 120

  source_code_hash = data.archive_file.lambda-exporter-code.output_base64sha256

  runtime = "nodejs14.x"

  depends_on = [
    data.archive_file.lambda-exporter-code
  ]

  #  vpc_config {
  #   subnet_ids         = data.aws_subnet_ids.public.ids
  #   security_group_ids = [aws_security_group.exporter-lambda.id]
  # }

  environment {
    variables = {
      SERVICE_URL      = "http://${aws_lb.alb.dns_name}",
      SERVICE_AUTH_KEY = "${var.service_auth_key}",
      TARGET_DIR       = "default"
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
  batch_size       = 5
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

resource "aws_iam_role_policy_attachment" "exporter_eni_role_attachement" {
  role       = aws_iam_role.exporter-lambda.name
  policy_arn = "arn:aws:iam::aws:policy/service-role/AWSLambdaENIManagementAccess"
}

resource "aws_cloudwatch_log_group" "exporter-lambda" {
  name = "/aws/lambda/${aws_lambda_function.exporter.function_name}"

  retention_in_days = 30
}

resource "aws_security_group" "exporter-lambda" {
  name        = "config-creator-exporter-lambda"
  vpc_id      = aws_vpc.main.id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    env = "prod"
    terraform = "true"
  }
}


data "archive_file" "lambda-exporter-code" {
  type = "zip"

  source_dir  = "${path.module}/config-creator-exporter/src/lambda"
  # source_dir  = data.null_data_source.wait_for_lambda_exporter.outputs["source_dir"]
  output_path = "${path.module}/config-creator-exporter.zip"

  depends_on = [
    null_resource.lambda_dependencies
  ]
}

resource "null_resource" "lambda_dependencies" {
  provisioner "local-exec" {
    command = "cd ${path.module}/config-creator-exporter/src/lambda && npm install"
  }

  triggers = {
    index = sha256(file("${path.module}/config-creator-exporter/src/lambda/index.js"))
    package = sha256(file("${path.module}/config-creator-exporter/src/lambda/package.json"))
    lock = sha256(file("${path.module}/config-creator-exporter/src/lambda/package-lock.json"))
    node = sha256(join("",fileset(path.module, "config-creator-exporter/src/lambda/service/*.js")))
  }
}

# data "null_data_source" "wait_for_lambda_exporter" {
#   inputs = {
#     lambda_dependency_id = null_resource.lambda_dependencies.id
#     source_dir           = "${path.module}/config-creator-exporter/src/lambda"
#   }
# }