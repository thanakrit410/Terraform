resource "aws_instance" "kubectl-server" {
  ami                         = "ami-063e1495af50e6fd5"
  key_name                    = "PTG-sandbox-keypair"
  instance_type               = "t3.medium"
  associate_public_ip_address = false
  subnet_id                   = aws_subnet.subnet_az1.id
  vpc_security_group_ids      = [aws_security_group.eks_worker_nodes.id]


  root_block_device {
    volume_size = 100
    volume_type = "gp2"
  }

  tags = {
    Name = "kubectl"
  }

}

resource "aws_eks_node_group" "node-grp" {
  cluster_name    = aws_eks_cluster.eks.name
  node_group_name = "pc-node-group"
  node_role_arn   = aws_iam_role.worker.arn
  subnet_ids      = [aws_subnet.subnet_az1.id, aws_subnet.subnet_az2.id]
  capacity_type   = "ON_DEMAND"
  disk_size       = "100"
  instance_types  = ["t3.medium"]

  remote_access {
    ec2_ssh_key               = "PTG-sandbox-keypair"
    source_security_group_ids = [aws_security_group.eks_worker_nodes.id]
  }

  labels = tomap({ env = "dev" })

  scaling_config {
    desired_size = 2
    max_size     = 3
    min_size     = 1
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    #aws_subnet.pub_sub1,
    #aws_subnet.pub_sub2,
  ]
}
