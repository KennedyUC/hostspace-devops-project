resource "aws_eks_addon" "eks_cluster_ebs_csi_addon" {
  cluster_name             = "${var.project_name}-${var.env}-k8s"
  addon_name               = "aws-ebs-csi-driver"
  addon_version            = "v1.25.0-eksbuild.1"
  service_account_role_arn = aws_iam_role.eks_cluster_ebs_csi_role.arn
  depends_on = [
    aws_iam_role_policy_attachment.eks_cluster_ebs_csi_role_policy_attach,
    aws_iam_role.eks_cluster_ebs_csi_role
  ]
  tags = {
    tag-key = "${var.project_name}-${var.env}-k8s-ebs-csi-addon"
  }
}