resource "kubernetes_service_account" "ebs_csi_controller_sa" {
  metadata {
    name      = "ebs-csi-controller-sa"
    namespace = var.app_namespace

    labels = {
      "app.kubernetes.io/component" = "csi-driver"
      "app.kubernetes.io/managed-by" = "EKS"
      "app.kubernetes.io/name"       = "aws-ebs-csi-driver"
      "app.kubernetes.io/version"    = "1.25.0"
    }

    annotations = {
      "eks.amazonaws.com/role-arn" = aws_iam_role.eks_cluster_ebs_csi_role.arn
    }
  }

  depends_on = [kubernetes_namespace.namespaces]
}