resource "aws_route_table" "rtb_public" {
  vpc_id = aws_vpc.main.id

# embedded approach
  # route {
  #   cidr_block = "0.0.0.0/0"
  #   gateway_id = aws_internet_gateway.igw.id
  # }

  tags = {
    Name      = "config-creator-vpc-public-rt"
    env       = "prod"
    terraform = "true"
  }
}

resource "aws_route" "aws_route_public_to_igw" {
    destination_cidr_block = "0.0.0.0/0"
    route_table_id         = aws_route_table.rtb_public.id
    gateway_id             = aws_internet_gateway.igw.id
}

resource "aws_route_table_association" "rta_subnet_public0" {
    subnet_id = aws_subnet.subnet_public0.id
    route_table_id = aws_route_table.rtb_public.id
}

resource "aws_route_table_association" "rta_subnet_public1" {
    subnet_id = aws_subnet.subnet_public1.id
    route_table_id = aws_route_table.rtb_public.id
}

resource "aws_route_table" "rtb_private" {
  vpc_id = aws_vpc.main.id

  tags = {
    Name      = "config-creator-vpc-private-rt0"
    env       = "prod"
    terraform = "true"
  }
}

resource "aws_route_table_association" "rta_subnet_private0" {
    subnet_id = aws_subnet.subnet_private0.id
    route_table_id = aws_route_table.rtb_private.id
}

resource "aws_route_table_association" "rta_subnet_private1" {
    subnet_id = aws_subnet.subnet_private1.id
    route_table_id = aws_route_table.rtb_private.id
}