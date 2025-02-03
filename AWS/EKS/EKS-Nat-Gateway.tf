resource "aws_eip" "nat_eip" {
  domain = "vpc"

  tags = {
    Name = "eks-nat-eip"
  }
}

resource "aws_nat_gateway" "nat_gw" {
  allocation_id = aws_eip.nat_eip.id
  subnet_id     = aws_subnet.subnet_az3.id

  tags = {
    Name = "eks-nat-gateway"
  }
}

resource "aws_route_table" "private_rtb" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_nat_gateway.nat_gw.id
  }

  tags = {
    Name = "Private-Route-Table"
  }
}

resource "aws_route_table_association" "private_rtb_assoc_az1" {
  subnet_id      = aws_subnet.subnet_az1.id
  route_table_id = aws_route_table.private_rtb.id
}

resource "aws_route_table_association" "private_rtb_assoc_az2" {
  subnet_id      = aws_subnet.subnet_az2.id
  route_table_id = aws_route_table.private_rtb.id
}


