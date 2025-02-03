resource "aws_route_table" "public_rtb" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "Public-Route-Table"
  }
}

resource "aws_route_table_association" "public_rtb_assoc" {
  subnet_id      = aws_subnet.subnet_az3.id
  route_table_id = aws_route_table.public_rtb.id
}
