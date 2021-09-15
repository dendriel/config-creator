data "aws_ami" "amazon_linux" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn-ami*amazon-ecs-optimized"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon", "self"]
}

resource "aws_security_group" "ec2-sg" {
  name        = "ecs-client-allow-all"
  description = "Allow all"
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

resource "aws_launch_configuration" "lc" {
  name                        = "ecs-client-lc"
  image_id                    = data.aws_ami.amazon_linux.id
  instance_type               = "t2.micro"
  iam_instance_profile        = aws_iam_instance_profile.ecs_service_role.name
  key_name                    = var.launch_configuration_key_name
  security_groups             = [aws_security_group.ec2-sg.id]
  associate_public_ip_address = true

  user_data                   = <<EOF
#! /bin/bash
sudo apt-get update
sudo echo "ECS_CLUSTER=config-creator" >> /etc/ecs/ecs.config
EOF

  lifecycle {
    create_before_destroy = true
  }
}

resource "aws_autoscaling_group" "asg" {
  name                      = "ecs-clients-asg"
  launch_configuration      = aws_launch_configuration.lc.name
  min_size                  = 0
  desired_capacity          = 0
  max_size                  = 5
  health_check_type         = "ELB"
  health_check_grace_period = 300
  vpc_zone_identifier       = data.aws_subnet_ids.public.ids

  protect_from_scale_in = false

  lifecycle {
    create_before_destroy = true
    # avoid reseting desired capacity to 0 on aws
    ignore_changes = [desired_capacity]
  }
}