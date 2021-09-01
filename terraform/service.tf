# update file container-def, so it's pulling image from ecr
resource "aws_ecs_task_definition" "front" {
  family                = "config-creator-front"
  container_definitions = file("container-definitions/config-creator-front.json")
  network_mode          = "bridge"

  tags = {
    env = "prod"
    terraform = "true"
  }
}

resource "aws_ecs_service" "front" {
  name            = "config-creator-front"
  cluster         = aws_ecs_cluster.config-creator.id
  task_definition = aws_ecs_task_definition.front.arn
  desired_count   = 1

  ordered_placement_strategy {
    type  = "binpack"
    field = "cpu"
  }

  load_balancer {
    target_group_arn = aws_lb_target_group.alb.arn
    container_name   = "config-creator-front"
    container_port   = 80
  }

  # Optional: Allow external changes without Terraform plan difference(for example ASG)
  lifecycle {
    ignore_changes = [desired_count]
  }

  launch_type = "EC2"
  depends_on  = [aws_lb_listener.config-creator-front-rule]
}

resource "aws_cloudwatch_log_group" "log_group" {
  name = "/ecs/config-creator-front"

  tags = {
    env = "prod"
    terraform = "true"
  }
}