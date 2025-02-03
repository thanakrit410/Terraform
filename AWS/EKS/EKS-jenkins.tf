resource "null_resource" "configure_kubectl" {
  provisioner "local-exec" {
    command = <<EOT
      aws eks --region ap-southeast-1 update-kubeconfig --name sandbox-eks
    EOT
  }
  depends_on = [
    aws_eks_cluster.eks
  ]

}

resource "null_resource" "apply_kubernetes_yaml" {
  provisioner "local-exec" {
    command = "bash ./shell-script/jenkis-deployment.sh"
  }

  depends_on = [
    aws_eks_cluster.eks,
    null_resource.configure_kubectl
  ]
}





