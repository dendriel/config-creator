data "aws_ami" "amazon_linux_default" {
  most_recent = true

  filter {
    name   = "name"
    values = ["amzn2-ami-hvm-*-x86_64-gp2"]
  }

  filter {
    name   = "architecture"
    values = ["x86_64"]
  }

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
  owners = ["amazon", "self"]
}


resource "aws_instance" "mongodb" {
  ami           = data.aws_ami.amazon_linux_default.id
  instance_type = "t2.micro"
  key_name      = var.launch_configuration_key_name
  subnet_id     = aws_subnet.subnet_public1.id

  security_groups   = [ aws_security_group.mongodb-sg.id ]

  user_data         = <<EOF
#! /bin/bash
sudo su
yum update -y
wget https://repo.mongodb.org/yum/amazon/mongodb-org-3.0.repo -P /etc/yum.repos.d/
yum install -y mongodb-org
sed -i '/bindIp: /s/127.0.0.1/0.0.0.0/' /etc/mongodb.conf
service mongod restart
mongo
use admin
db.createUser({user: '${var.mongodb.user}', pwd: '${var.mongodb.pass}', roles: [{role: 'readWrite', db: '${var.mongodb.name}'}]})
EOF

  lifecycle {
    ignore_changes = [ami]
  }

  depends_on = [
    aws_security_group.mongodb-sg
  ]

  tags = {
    Name      = "config-creator-mongodb"
    env       = "prod"
    terraform = "true"
  }
}

# only if we want an extra volume (or a persistent one) 
# resource "aws_ebs_volume" "mongodb" {
#      availability_zone = var.vpc.azs[0]
#      size              = 8
#      type              = "gp2"
# }

# resource "aws_volume_attachment" "mongodb-ebs-att" {
#      device_name = "/dev/sdh"
#      volume_id   = aws_ebs_volume.mongodb.id
#      instance_id = aws_instance.mongodb.id
# }

resource "aws_security_group" "mongodb-sg" {
  # description = "Allow ssh connection"
  vpc_id      = aws_vpc.main.id

  # ingress {
  #   from_port        = 22
  #   to_port          = 22
  #   protocol         = "tcp"
  #   cidr_blocks      = ["0.0.0.0/0"]
  # }
  ingress {
    from_port        = 27017
    to_port          = 27018
    protocol         = "tcp"
    # cidr_blocks      = ["172.31.0.0/16"] # TODO sg group from ecs instances
    security_groups  = [ aws_security_group.ec2-sg.id ]
  }

  egress {
      from_port        = 0
      to_port          = 0
      protocol         = "-1"
      cidr_blocks      = ["0.0.0.0/0"]
  }

  tags = {
    Name      = "config-creator-mongodb"
    env       = "prod"
    terraform = "true"
  }
}

resource "aws_cloudwatch_metric_alarm" "cloudwatch-metric-alarm-mongodb-cpu" {
     alarm_name                = "mongodb-instance-cpu-utilization"
     comparison_operator       = "GreaterThanOrEqualToThreshold"
     evaluation_periods        = "2"
     metric_name               = "CPUUtilization"
     namespace                 = "AWS/EC2"
     period                    = "120"
     statistic                 = "Average"
     threshold                 = "80"
     alarm_description         = "This metric monitors ec2 cpu utilization from mongoDB"
     insufficient_data_actions = []

  dimensions = {
    InstanceId = aws_instance.mongodb.id
  }
}