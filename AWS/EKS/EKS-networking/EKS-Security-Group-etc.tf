resource "aws_security_group" "rds_access" {
  name        = "eks_rds_access"
  description = "Allow EKS Pods to access RDS"
  vpc_id      = aws_vpc.eks_vpc.id

  ingress {
    description     = "Allow traffic from EKS Pods"
    from_port       = 5432
    to_port         = 5432
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
    Name = "rds_access"
  }
}
