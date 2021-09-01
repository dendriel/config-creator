resource "aws_lb" "alb" {
  name               = "config-creator-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = module.vpc.public_subnets
  security_groups = [aws_security_group.alb-sg.id]
  
  enable_deletion_protection = false

  tags = {
    env = "prod"
    terraform = "true"
  }
}

resource "aws_security_group" "alb-sg" {
  name   = "config-creator-alb-sg"
  vpc_id = data.aws_vpc.main.id
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

  lifecycle {
      create_before_destroy = true
  }

  tags = {
    env = "prod"
    terraform = "true"
  }
}

resource "aws_lb_target_group" "alb" {
  name        = "config-creator-alb-target-group"
  port        = "80"
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = data.aws_vpc.main.id
  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 60
    interval            = 300
    matcher             = "200,301,302"
  }
}

resource "aws_lb_listener" "config-creator-front-rule" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.alb.arn
  }
}