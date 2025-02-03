resource "aws_security_group" "eks_worker_nodes" {
  name        = "eks_worker_nodes"
  description = "Security Group for EKS Worker Nodes"
  vpc_id      = aws_vpc.eks_vpc.id

  ingress {
    description = "Allow traffic from Load Balancer"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow HTTPS traffic from Load Balancer"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  # ingress {
  #   description = "Allow Node-to-Node communication"
  #   from_port   = 0
  #   to_port     = 65535
  #   protocol    = "tcp"
  #   self        = true
  # }

  # ingress {
  #   description = "TLS from VPC"
  #   from_port   = 22
  #   to_port     = 22
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks_worker_nodes"
  }
}
