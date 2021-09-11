resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.main.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.igw.id
  }

  tags = {
    Name      = "config-creator-vpc-public-rt"
    env       = "prod"
    terraform = "true"
  }
}

resource "aws_route_table_association" "rta_subnet_public0" {
    subnet_id = aws_subnet.subnet_public0.id
    route_table_id = aws_route_table.rtb_public.id
}

resource "aws_route_table_association" "rta_subnet_public1" {
    subnet_id = aws_subnet.subnet_public1.id
    route_table_id = aws_route_table.rtb_public.id
}

resource "aws_route_table" "rtb_private0" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name      = "config-creator-vpc-private-rt0"
    env       = "prod"
    terraform = "true"
  }
}

resource "aws_route_table_association" "rta_subnet_private0" {
    subnet_id = aws_subnet.subnet_private0.id
    route_table_id = aws_route_table.rtb_private0.id
}

resource "aws_route_table" "rtb_private1" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name      = "config-creator-vpc-private-rt1"
    env       = "prod"
    terraform = "true"
  }
}

resource "aws_route_table_association" "rta_subnet_private1" {
    subnet_id = aws_subnet.subnet_private1.id
    route_table_id = aws_route_table.rtb_private1.id
}