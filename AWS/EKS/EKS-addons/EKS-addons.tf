resource "aws_eks_addon" "coredns" {
  cluster_name  = "sandbox-eks"
  addon_name    = "coredns"
  addon_version = "v1.11.1-eksbuild.11"
}

resource "aws_eks_addon" "kubeproxy" {
  cluster_name = "sandbox-eks"
  addon_name   = "kube-proxy"
}