variable "name" {
  description = "Service name to tag related resources"
}

variable "container_image" {
  description = "Container image location"
}

variable "container_port" {
  description = "Binding container port"
  type        = number
}

variable "container_cpu" {
  description = "Container CPU units"
  type        = number
  default     = 128
}

variable "container_memory" {
  description = "Container memory in MBs"
  type        = number
  default     = 256
}

variable "container_environment" {
  description = "Container environment variables, if any"
  type        = list
  default     = []
}

variable "region" {
  description = "Target aws region"
}

variable "cluster_id" {
  description = "Target cluster ID"
}

variable "vpc_id" {
  description = "Target VPC ID"
}

variable "capacity_provider_name" {
  description = "Target capacity provider name"
}

variable "load_balancer" {
    type = object({
        health_check_path    = string
        health_check_matcher = string
    })
}

variable "lb_listener_rule" {
  type = object({
      arn          = string
      priority     = number
      host_headers = list(string)
      path_pattern = optional(list(string))
  })
}

variable "desired_count" {
  description = "Desired number of tasks"
  default     = 1
}