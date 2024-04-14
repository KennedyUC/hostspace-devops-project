// resource "kubernetes_namespace" "argocd" {  
//   metadata {
//     name = var.argocd_namespace
//   }

//   depends_on = [aws_eks_node_group.eks_nodes]
// }

// resource "kubernetes_namespace" "monitoring" {  
//   metadata {
//     name = var.promstack_namespace
//   }

//   depends_on = [aws_eks_node_group.eks_nodes]
// }

// resource "kubernetes_namespace" "webapp" {  
//   metadata {
//     name = var.app_namespace
//   }

//   depends_on = [aws_eks_node_group.eks_nodes]
// }

// resource "kubernetes_namespace" "ingress" {  
//   metadata {
//     name = var.ingress_namespace
//   }

//   depends_on = [aws_eks_node_group.eks_nodes]
// }

// resource "kubernetes_namespace" "sealed-secret" {  
//   metadata {
//     name = var.sealed_secret_namespace
//   }

//   depends_on = [aws_eks_node_group.eks_nodes]
// }

resource "kubernetes_namespace" "namespaces" {
  count = length(var.namespaces)

  metadata {
    name = var.namespaces[count.index]
  }

  depends_on = [aws_eks_node_group.eks_nodes]
}