#
# To be used when ec2 instances from ecs cluster are in private subnet. But it also
# needs a NAT gateway.
#
resource "aws_vpc_endpoint" "ecs" {
  vpc_id             = aws_vpc.main.id
  service_name       = "com.amazonaws.${var.region}.ecs"
  subnet_ids         = data.aws_subnet_ids.private.ids
  security_group_ids = [aws_security_group.vpc-endpoints.id]
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true

  policy             = <<EOF
{
    "Statement": [
        {
            "Action": "*",
            "Effect": "Allow",
            "Resource": "*",
            "Principal": "*"
        }
    ]
}
EOF

  tags = {
    env = "prod"
    terraform = "true"
  }
}

resource "aws_vpc_endpoint" "ecs-agent" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.region}.ecs-agent"
  subnet_ids         = data.aws_subnet_ids.private.ids
  security_group_ids = [aws_security_group.vpc-endpoints.id]
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true

  policy             = <<EOF
{
    "Statement": [
        {
            "Action": "*",
            "Effect": "Allow",
            "Resource": "*",
            "Principal": "*"
        }
    ]
}
EOF

  tags = {
    env = "prod"
    terraform = "true"
  }
}

resource "aws_vpc_endpoint" "ecs-telemetry" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.region}.ecs-telemetry"
  subnet_ids         = data.aws_subnet_ids.private.ids
  security_group_ids = [aws_security_group.vpc-endpoints.id]
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true

  policy             = <<EOF
{
    "Statement": [
        {
            "Action": "*",
            "Effect": "Allow",
            "Resource": "*",
            "Principal": "*"
        }
    ]
}
EOF

  tags = {
    env = "prod"
    terraform = "true"
  }
}

resource "aws_vpc_endpoint" "ecr-dkr" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.region}.ecr.dkr"
  subnet_ids         = data.aws_subnet_ids.private.ids
  security_group_ids = [aws_security_group.vpc-endpoints.id]
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true

  policy             = <<EOF
{
    "Statement": [
        {
            "Action": "*",
            "Effect": "Allow",
            "Resource": "*",
            "Principal": "*"
        }
    ]
}
EOF

  tags = {
    env = "prod"
    terraform = "true"
  }
}

resource "aws_vpc_endpoint" "ecr-api" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.region}.ecr.api"
  subnet_ids         = data.aws_subnet_ids.private.ids
  security_group_ids = [aws_security_group.vpc-endpoints.id]
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true

  policy             = <<EOF
{
    "Statement": [
        {
            "Action": "*",
            "Effect": "Allow",
            "Resource": "*",
            "Principal": "*"
        }
    ]
}
EOF

  tags = {
    env = "prod"
    terraform = "true"
  }
}

resource "aws_vpc_endpoint" "logs" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.region}.logs"
  subnet_ids         = data.aws_subnet_ids.private.ids
  security_group_ids = [aws_security_group.vpc-endpoints.id]
  vpc_endpoint_type = "Interface"
  private_dns_enabled = true

  policy             = <<EOF
{
    "Statement": [
        {
            "Action": "*",
            "Effect": "Allow",
            "Resource": "*",
            "Principal": "*"
        }
    ]
}
EOF

  tags = {
    env = "prod"
    terraform = "true"
  }
}

resource "aws_vpc_endpoint" "s3-for-ecs" {
  vpc_id       = aws_vpc.main.id
  service_name = "com.amazonaws.${var.region}.s3"
  vpc_endpoint_type = "Gateway"
  route_table_ids = [aws_route_table.rtb_private.id]

  policy             = <<EOF
{
    "Statement": [
        {
            "Action": "*",
            "Effect": "Allow",
            "Resource": "*",
            "Principal": "*"
        }
    ]
}
EOF

  tags = {
    env = "prod"
    terraform = "true"
  }
}

resource "aws_security_group" "vpc-endpoints" {
  name        = "vpc-endpoints"
  vpc_id      = aws_vpc.main.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }
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