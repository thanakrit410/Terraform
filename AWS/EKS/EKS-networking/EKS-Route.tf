resource "aws_route_table" "rtb" {
  vpc_id = aws_vpc.eks_vpc.id

  route {
    cidr_block = "0.0.0.0/0"
    gateway_id = aws_internet_gateway.gw.id
  }

  tags = {
    Name = "eks-route"
  }
}

resource "aws_route_table_association" "a-1" {
  subnet_id      = aws_subnet.subnet_az1.id
  route_table_id = aws_route_table.rtb.id
}
