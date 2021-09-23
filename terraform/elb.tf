resource "aws_lb" "alb" {
  name               = "config-creator-alb"
  internal           = false
  load_balancer_type = "application"
  subnets            = data.aws_subnet_ids.public.ids
  security_groups    = [aws_security_group.alb-sg.id]
  
  enable_deletion_protection = false

  tags = {
    env = "prod"
    terraform = "true"
  }
}

resource "aws_security_group" "alb-sg" {
  name   = "config-creator-alb-sg"
  vpc_id = aws_vpc.main.id
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

resource "aws_lb_listener" "config-creator-lb-listener" {
  load_balancer_arn = aws_lb.alb.arn
  port              = "80"
  protocol          = "HTTP"
  default_action {
    type = "fixed-response"

    fixed_response {
      content_type = "text/plain"
      message_body = "Not Found"
      status_code  = "404"
    }
  }
}

resource "aws_lb_listener_rule" "config-creator-front-rule" {
  listener_arn = aws_lb_listener.config-creator-lb-listener.arn
  priority     = 1000

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.front-end-lb-target-group.arn
  }

  condition {
    host_header {
      values = [aws_lb.alb.dns_name]
    }
  }
}

resource "aws_lb_listener_rule" "config-creator-auth-rule" {
  listener_arn = aws_lb_listener.config-creator-lb-listener.arn
  priority     = 70

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.auth-lb-target-group.arn
  }

  condition {
    host_header {
      values = [aws_lb.alb.dns_name]
    }
  }

  condition {
    path_pattern {
      values = ["/auth/*"]
    }
  }
}

resource "aws_lb_listener_rule" "config-creator-rest-rule" {
  listener_arn = aws_lb_listener.config-creator-lb-listener.arn
  priority     = 80

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.rest-lb-target-group.arn
  }

  condition {
    host_header {
      values = [aws_lb.alb.dns_name]
    }
  }

  condition {
    path_pattern {
      values = ["/rest/*"]
    }
  }
}

resource "aws_lb_listener_rule" "config-creator-storage-rule" {
  listener_arn = aws_lb_listener.config-creator-lb-listener.arn
  priority     = 90

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.storage-lb-target-group.arn
  }

  condition {
    host_header {
      values = [aws_lb.alb.dns_name]
    }
  }

  condition {
    path_pattern {
      values = ["/storage/*"]
    }
  }
}