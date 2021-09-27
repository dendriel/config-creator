resource "aws_ecs_cluster" "config-creator" {
  name               = "config-creator"
  capacity_providers = [aws_ecs_capacity_provider.capacity-provider.name]

  depends_on = [aws_ecs_capacity_provider.capacity-provider, aws_internet_gateway.igw]

  tags = {
    env       = "prod"
    terraform = "true"
  }
}

resource "aws_ecs_capacity_provider" "capacity-provider" {
  name = "config-creator-capacity-provider"
  auto_scaling_group_provider {
    auto_scaling_group_arn         = aws_autoscaling_group.asg.arn
    managed_termination_protection = "DISABLED"

    managed_scaling {
      status          = "ENABLED"
      target_capacity = 100
      minimum_scaling_step_size = 1
      maximum_scaling_step_size = 1
    }
  }

    depends_on = [aws_autoscaling_group.asg]
}