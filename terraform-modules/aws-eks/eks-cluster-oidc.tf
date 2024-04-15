data "tls_certificate" "eks_cluster" {
  url = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer
}

resource "aws_iam_openid_connect_provider" "cluster_iodc_provider" {
  client_id_list  = ["sts.amazonaws.com"]
  thumbprint_list = [data.tls_certificate.eks_cluster.certificates[0].sha1_fingerprint]
  url             = aws_eks_cluster.eks_cluster.identity[0].oidc[0].issuer

  tags = {
    name = "${var.project_name}-${var.env}-eks-oidc"
  }
}

locals {
  eks_cluster_openid_provider_arn = element(split("oidc-provider/", "${aws_iam_openid_connect_provider.cluster_iodc_provider.arn}"), 1)
}