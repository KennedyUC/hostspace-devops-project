resource "aws_eks_cluster" "eks_cluster" {
  name                    = "${var.project_name}-${var.env}-k8s"
  role_arn                = aws_iam_role.EKSClusterRole.arn
  version                 = var.k8s_version

  vpc_config {
    subnet_ids = flatten([var.public_subnet_ids, var.private_subnet_ids])
  }

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSClusterPolicy
  ]

  tags = {
    Name = "${var.project_name}-${var.env}-k8s-cluster"
  }
}