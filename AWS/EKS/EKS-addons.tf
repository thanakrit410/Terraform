data "aws_eks_cluster" "eks" {
  name = "sandbox-eks"
  depends_on = [
    aws_eks_cluster.eks
  ]
}

data "aws_eks_cluster_auth" "eks" {
  name = "sandbox-eks"
  depends_on = [
    aws_eks_cluster.eks
  ]
}

provider "kubernetes" {
  host                   = data.aws_eks_cluster.eks.endpoint
  cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
  token                  = data.aws_eks_cluster_auth.eks.token
}

provider "helm" {
  kubernetes {
    host                   = data.aws_eks_cluster.eks.endpoint
    cluster_ca_certificate = base64decode(data.aws_eks_cluster.eks.certificate_authority[0].data)
    token                  = data.aws_eks_cluster_auth.eks.token
  }
}


resource "aws_eks_addon" "coredns" {
  cluster_name  = "sandbox-eks"
  addon_name    = "coredns"
  addon_version = "v1.11.1-eksbuild.11"

  depends_on = [
    aws_eks_cluster.eks
  ]
}

resource "aws_eks_addon" "kubeproxy" {
  cluster_name = "sandbox-eks"
  addon_name   = "kube-proxy"

  depends_on = [
    aws_eks_cluster.eks
  ]
}


resource "helm_release" "nginx_ingress" {
  name             = "nginx-ingress"
  namespace        = "ingress-nginx"
  create_namespace = true

  repository = "https://kubernetes.github.io/ingress-nginx"
  chart      = "ingress-nginx"
  version    = "4.8.1"

  values = [
    <<EOF
controller:
  service:
    type: LoadBalancer
    annotations:
      service.beta.kubernetes.io/aws-load-balancer-backend-protocol: "http"
      service.beta.kubernetes.io/aws-load-balancer-ssl-ports: "443"
    externalTrafficPolicy: Cluster
EOF
  ]
}
