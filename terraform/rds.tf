resource "aws_db_instance" "config-creator" {
    name = var.db.name
    allocated_storage = 10
    engine  = "mysql"
    engine_version = "8.0.23"
    instance_class = "db.t2.micro"
    username = var.db.user
    password = var.db.pass
    skip_final_snapshot = true
    publicly_accessible = false
    db_subnet_group_name = aws_db_subnet_group.config-creator-db.id

    vpc_security_group_ids = [aws_security_group.rds-sg.id]
}

resource "aws_db_subnet_group" "config-creator-db" {
  name = "config-creator"
  subnet_ids = module.vpc.private_subnets
}

resource "aws_security_group" "rds-sg" {
  name        = "rds-sg"
  description = "Allow RDS traffic"
  vpc_id      = data.aws_vpc.main.id

  ingress {
    protocol    = "tcp"
    from_port   = 3306
    to_port     = 3306
    cidr_blocks = [module.vpc.vpc_cidr_block]
  }

  egress {
    protocol    = -1
    from_port   = 0
    to_port     = 0
    cidr_blocks = ["0.0.0.0/0"]
  }

  lifecycle {
    create_before_destroy = true
  }

  tags = {
    env = "prod"
    terraform = "true"
  }
}