locals {
  services = {
    front_service = {
        name  = "config-creator-front"
        container_image = "public.ecr.aws/l3o8c7n1/dendriel/config-creator-front:latest"
        container_port  = 80

        load_balancer = {
          health_check_path    = "/"
          health_check_matcher = "200,301,302"
        }

        lb_listener_rule = {
            priority     = 1000
            path_pattern = ["*"]
        }

        container_environment = null
    }

    auth_service = {
      name  = "config-creator-auth"
      container_image = "public.ecr.aws/l3o8c7n1/dendriel/npc-data-manager-auth:latest"
      container_port  = 8080

      load_balancer = {
        health_check_path    = "/actuator/health"
        health_check_matcher = "200"
      }

      lb_listener_rule = {
          priority     = 70
          path_pattern = ["/auth/*"]
      }

      container_environment = [
          { "name": "BASE_PATH",  "value": "/auth" },
          { "name": "MYSQL_HOST", "value": "${aws_db_instance.config-creator.address}" },
          { "name": "MYSQL_DB",   "value": "${aws_db_instance.config-creator.name}" },
          { "name": "MYSQL_USER", "value": "${var.db.user}" },
          { "name": "MYSQL_PASS", "value": "${var.db.pass}" }
        ]
      }

    rest_service = {
      name  = "config-creator-rest"
      container_image = "public.ecr.aws/l3o8c7n1/dendriel/config-creator-rest:latest"
      container_port  = 8081

      load_balancer = {
        health_check_path    = "/actuator/health"
        health_check_matcher = "200"
      }

      lb_listener_rule = {
          priority     = 80
          path_pattern = ["/rest/*"]
      }

      container_environment = [
        { "name": "BASE_PATH",             "value": "/rest" },
        { "name": "SERVICE_URL",           "value": "${aws_lb.alb.dns_name}" },
        { "name": "SERVICE_AUTH_KEY",      "value": "${var.service_auth_key}" },
        { "name": "MONGO_DB_HOST",         "value": "${aws_instance.mongodb.private_dns}" },
        { "name": "MONGO_DB_NAME",         "value": "${var.mongodb.name}" },
        { "name": "MONGO_DB_USER",         "value": "${var.mongodb.user}" },
        { "name": "MONGO_DB_PASS",         "value": "${var.mongodb.pass}" },
        { "name": "EXPORTER_ENABLED",      "value": "true"},
        { "name": "EXPORTER_QUEUE_REGION", "value": "${var.region}"},
        { "name": "EXPORTER_QUEUE_NAME",   "value": "${aws_sqs_queue.exporter-queue.name}"},
        { "name": "EXPORTER_QUEUE_URL",    "value": regex("^(http[s]?://sqs.*)/", "${aws_sqs_queue.exporter-queue.url}")[0] },
        { "name": "AWS_ACCESS_KEY_ID",     "value": "${var.aws_access_key_id}" },
        { "name": "AWS_SECRET_KEY",        "value": "${var.aws_secret_key}" }
      ]
    }

    storage_service = {
      name  = "config-creator-storage"
      container_image = "public.ecr.aws/l3o8c7n1/dendriel/npc-data-manager-storage:latest"
      container_port  = 8082

      load_balancer = {
        health_check_path    = "/actuator/health"
        health_check_matcher = "200"
      }

      lb_listener_rule = {
          priority     = 90
          path_pattern = ["/storage/*"]
      }

      container_environment = [
        { "name": "BASE_PATH",         "value": "/storage" },
        { "name": "SERVICE_URL",       "value": "${aws_lb.alb.dns_name}" },
        { "name": "AWS_ACCESS_KEY_ID", "value": "${var.aws_access_key_id}" },
        { "name": "AWS_SECRET_KEY",    "value": "${var.aws_secret_key}" },
        { "name": "MYSQL_HOST",        "value": "${aws_db_instance.config-creator.address}" },
        { "name": "MYSQL_DB",          "value": "${aws_db_instance.config-creator.name}" },
        { "name": "MYSQL_USER",        "value": "${var.db.user}" },
        { "name": "MYSQL_PASS",        "value": "${var.db.pass}" },
        { "name": "STORAGE_BUCKET_NAME", "value": "${var.storage_bucket_name}" }
      ]
    }
  }
}

module "ecs_service" {
  source = "./ecs_service"

  for_each = local.services

  name                  = each.value.name
  container_image       = each.value.container_image
  container_port        = each.value.container_port
  container_environment = each.value.container_environment
  load_balancer         = each.value.load_balancer

  region                 = var.region
  cluster_id             = aws_ecs_cluster.config-creator.id
  vpc_id                 = aws_vpc.main.id
  capacity_provider_name = aws_ecs_capacity_provider.capacity-provider.name

  lb_listener_rule = {
      arn          = aws_lb_listener.config-creator-lb-listener.arn
      priority     = each.value.lb_listener_rule.priority
      path_pattern = each.value.lb_listener_rule.path_pattern
      host_headers = [aws_lb.alb.dns_name]
  }
}