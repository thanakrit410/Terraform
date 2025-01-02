resource "aws_security_group" "load_balancer" {
  depends_on  = [aws_security_group.eks_worker_nodes]
  name        = "eks-lb-sg"
  vpc_id      = aws_vpc.eks_vpc.id
  description = "Security Group for Load Balancer"

  ingress {
    description = "Allow inbound HTTP traffic from anywhere"
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description = "Allow inbound HTTPS traffic from anywhere"
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  ingress {
    description     = "Allow traffic to Worker Nodes on NodePort range"
    from_port       = 30000
    to_port         = 32767
    protocol        = "tcp"
    security_groups = [aws_security_group.eks_worker_nodes.id]
  }

  egress {
    description = "Allow all outbound traffic"
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "eks_ingress_lb"
  }
}
