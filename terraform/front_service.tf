resource "aws_ecs_task_definition" "front" {
  family                = "config-creator-front"
  network_mode          = "bridge"
  container_definitions = jsonencode([
    {
      "name": "config-creator-front",
      "image": "public.ecr.aws/l3o8c7n1/dendriel/config-creator-front:latest",
      "cpu": 128,
      "memory": 256,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 80
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": { 
          "awslogs-group" : "/ecs/config-creator-front",
          "awslogs-region": "sa-east-1"
        }
      }
    }
])

  tags = {
    env = "prod"
    terraform = "true"
  }
}

resource "aws_ecs_service" "front-service" {
  name            = "config-creator-front"
  cluster         = aws_ecs_cluster.config-creator.id
  task_definition = aws_ecs_task_definition.front.arn
  desired_count   = 1
  health_check_grace_period_seconds  = 60

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.front-end-lb-target-group.arn
    container_name   = "config-creator-front"
    container_port   = 80
  }

  # Optional: Allow external changes without Terraform plan difference(for example ASG)
  lifecycle {
    ignore_changes = [desired_count]
  }

  capacity_provider_strategy {
    base = 0
    weight = 1
    capacity_provider = aws_ecs_capacity_provider.capacity-provider.name
  }

  #launch_type = "EC2"
  depends_on  = [aws_lb_listener.config-creator-lb-listener]
}

resource "aws_cloudwatch_log_group" "front-service-log-group" {
  name = "/ecs/config-creator-front"

  tags = {
    env = "prod"
    terraform = "true"
  }
}

resource "aws_lb_target_group" "front-end-lb-target-group" {
  name        = "front-lb-target-group"
  port        = "80"
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id
  health_check {
    path                = "/"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 60
    interval            = 300
    matcher             = "200,301,302"
  }
}