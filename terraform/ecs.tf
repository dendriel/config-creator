resource "aws_ecs_cluster" "config-creator" {
  name               = "config-creator"
  capacity_providers = [aws_ecs_capacity_provider.capacity-provider.name]
  tags = {
    env       = "prod"
    terraform = "true"
  }
}

resource "aws_ecs_capacity_provider" "capacity-provider" {
  name = "config-creator-capacity-provider"
  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.asg.arn
    managed_termination_protection = "ENABLED"

    managed_scaling {
      status          = "ENABLED"
      target_capacity = 85
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 1
    }
  }
}