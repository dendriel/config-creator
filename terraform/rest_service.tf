resource "aws_ecs_task_definition" "rest" {
  family                = "config-creator-rest"
  network_mode          = "bridge"
  container_definitions = jsonencode([
    {
      "name": "config-creator-rest",
      "image": "registry.hub.docker.com/dendriel/config-creator-rest:latest",
      "cpu": 128,
      "memory": 256,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8081
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": { 
          "awslogs-group" : "/ecs/config-creator-rest",
          "awslogs-region": "sa-east-1"
        }
      },
      "environment": [
        { "name": "BASE_PATH",          "value": "/rest" },
        { "name": "SERVICE_URL",        "value": "${aws_lb.alb.dns_name}" },
        { "name": "SERVICE_AUTH_KEY",   "value": "${var.service_auth_key}" },
        { "name": "MONGO_DB_HOST",      "value": "${aws_instance.mongodb.private_dns}" },
        { "name": "MONGO_DB_NAME",      "value": "${var.mongodb.name}" },
        { "name": "MYSQL_USER",         "value": "${var.mongodb.user}" },
        { "name": "MYSQL_PASS",         "value": "${var.mongodb.pass}" },
        { "name": "EXPORTER_QUEUE_URL", "value": "http://localhost:9324" },
        { "name": "AWS_ACCESS_KEY_ID",  "value": "1111" },
        { "name": "AWS_SECRET_KEY",     "value": "2222" }
      ]
    }
])

  tags = {
    env = "prod"
    terraform = "true"
  }
}

resource "aws_ecs_service" "rest-service" {
  name            = "config-creator-rest"
  cluster         = aws_ecs_cluster.config-creator.id
  task_definition = aws_ecs_task_definition.rest.arn
  desired_count   = 1
  health_check_grace_period_seconds  = 60

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.rest-lb-target-group.arn
    container_name   = "config-creator-rest"
    container_port   = 8081
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
  depends_on  = [aws_lb_listener.config-creator-lb-listener, aws_instance.mongodb]
}

resource "aws_cloudwatch_log_group" "rest-service-log-group" {
  name = "/ecs/config-creator-rest"

  tags = {
    env = "prod"
    terraform = "true"
  }
}

resource "aws_lb_target_group" "rest-lb-target-group" {
  name        = "rest-lb-target-group"
  port        = "8081"
  protocol    = "HTTP"
  target_type = "instance"
  vpc_id      = aws_vpc.main.id
  health_check {
    path                = "/actuator/health"
    healthy_threshold   = 2
    unhealthy_threshold = 10
    timeout             = 60
    interval            = 300
    matcher             = "200"
  }
}