resource "kubernetes_namespace" "namespaces" {
  count = length(var.namespaces)

  metadata {
    name = var.namespaces[count.index]
  }

  depends_on = [aws_eks_node_group.eks_nodes]
}