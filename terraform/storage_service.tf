resource "aws_ecs_task_definition" "storage" {
  family                = "config-creator-storage"
  network_mode          = "bridge"
  container_definitions = jsonencode([
    {
      "name": "config-creator-storage",
      "image": "public.ecr.aws/l3o8c7n1/dendriel/npc-data-manager-storage:latest",
      "cpu": 128,
      "memory": 256,
      "essential": true,
      "portMappings": [
        {
          "containerPort": 8082
        }
      ],
      "logConfiguration": {
        "logDriver": "awslogs",
        "options": { 
          "awslogs-group" : "/ecs/config-creator-storage",
          "awslogs-region": "sa-east-1"
        }
      },
      "environment": [
        { "name": "BASE_PATH",         "value": "/storage" },
        { "name": "SERVICE_URL",       "value": "${aws_lb.alb.dns_name}" },
        { "name": "AWS_ACCESS_KEY_ID", "value": "${var.aws_access_key_id}" },
        { "name": "AWS_SECRET_KEY",    "value": "${var.aws_secret_key}" },
        { "name": "MYSQL_HOST",        "value": "${aws_db_instance.config-creator.address}" },
        { "name": "MYSQL_DB",          "value": "${aws_db_instance.config-creator.name}" },
        { "name": "MYSQL_USER",        "value": "${var.db.user}" },
        { "name": "MYSQL_PASS",        "value": "${var.db.pass}" }
      ]
    }
])

depends_on = [aws_ecs_task_definition.storage, aws_db_instance.config-creator]

  tags = {
    env = "prod"
    terraform = "true"
  }
}

resource "aws_ecs_service" "storage-service" {
  name            = "config-creator-storage"
  cluster         = aws_ecs_cluster.config-creator.id
  task_definition = aws_ecs_task_definition.storage.arn
  desired_count   = 1
  health_check_grace_period_seconds  = 60

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.storage-lb-target-group.arn
    container_name   = "config-creator-storage"
    container_port   = 8082
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

resource "aws_cloudwatch_log_group" "storage-service-log-group" {
  name = "/ecs/config-creator-storage"

  tags = {
    env = "prod"
    terraform = "true"
  }
}

resource "aws_lb_target_group" "storage-lb-target-group" {
  name        = "storage-lb-target-group"
  port        = "8082"
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