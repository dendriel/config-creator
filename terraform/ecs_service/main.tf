terraform {
  experiments = [module_variable_optional_attrs]
}

resource "aws_ecs_task_definition" "task_definition" {
  family                = var.name
  network_mode          = "bridge"
  container_definitions = jsonencode([
    {
      "name": "${var.name}",
      "image": "${var.container_image}",
      "cpu": "${var.container_cpu}",
      "memory": "${var.container_memory}",
      "essential": true,
      "portMappings": [
        {
          "containerPort": "${var.container_port}"
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": { 
          "awslogs-group" : "/ecs/${var.name}",
          "awslogs-region": "${var.region}"
        }
      },
      "environment": var.container_environment
    }
  ])

  tags = {
    env = "prod"
    terraform = "true"
  }
}

resource "aws_ecs_service" "ecs_service" {
  name            = var.name
  cluster         = var.cluster_id
  task_definition = aws_ecs_task_definition.task_definition.arn
  desired_count   = var.desired_count
  health_check_grace_period_seconds  = 60

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.lb_target_group.arn
    container_name   = var.name
    container_port   = var.container_port
  }

  # Optional: Allow external changes without Terraform plan difference(for example ASG)
  lifecycle {
    ignore_changes = [desired_count]
  }

  capacity_provider_strategy {
    base = 0
    weight = 1
    capacity_provider = var.capacity_provider_name
  }

  #launch_type = "EC2"
  #depends_on  = [aws_lb_listener.config-creator-lb-listener]
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "/ecs/${var.name}"

  tags = {
    env = "prod"
    terraform = "true"
  }
}

resource "aws_lb_target_group" "lb_target_group" {
  name        = var.name
  port        = var.container_port
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = var.vpc_id
  health_check {
    path                = var.load_balancer.health_check_path
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 60
    interval            = 300
    matcher             = var.load_balancer.health_check_matcher
  }
}

resource "aws_lb_listener_rule" "lb_listener_rule" {
  listener_arn = var.lb_listener_rule.arn
  priority     = var.lb_listener_rule.priority

  action {
    type             = "forward"
    target_group_arn = aws_lb_target_group.lb_target_group.arn
  }

  condition {
    host_header {
      values = var.lb_listener_rule.host_headers
    }
  }

  condition {
    path_pattern {
      values = var.lb_listener_rule.path_pattern
    }
  }
}