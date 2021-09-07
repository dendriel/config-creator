output "alb_dns" {
  value = aws_lb.alb.dns_name
}

output "rds_address" {
  value = aws_db_instance.config-creator.address
}