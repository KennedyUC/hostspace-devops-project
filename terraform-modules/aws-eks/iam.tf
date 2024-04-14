resource "aws_iam_role" "EKSClusterRole" {
  name = "${var.project_name}-${var.env}-cluster"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      },
    ]
  })
}

resource "aws_iam_role_policy_attachment" "AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.EKSClusterRole.name
  depends_on = [aws_iam_role.EKSClusterRole]
}

resource "aws_iam_role" "EKSNodeGroupRole" {
  name = "${var.project_name}-${var.env}-node"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      },
    ]
  })
  depends_on = [aws_eks_cluster.eks_cluster]
}

resource "aws_iam_role_policy_attachment" "AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.EKSNodeGroupRole.name
  depends_on = [aws_iam_role.EKSNodeGroupRole]
}

resource "aws_iam_role_policy_attachment" "AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.EKSNodeGroupRole.name
  depends_on = [aws_iam_role.EKSNodeGroupRole]
}

resource "aws_iam_role_policy_attachment" "AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.EKSNodeGroupRole.name
  depends_on = [aws_iam_role.EKSNodeGroupRole]
}

resource "aws_iam_policy" "eks_cluster_ebs_csi_iam_policy" {
  name        = "${var.project_name}-${var.env}-k8s-ebs-csi-policy"
  path        = "/"
  description = "EBS CSI IAM Policy"
  policy      = data.http.eks_cluster_ebs_csi_iam_policy.response_body
  tags = {
    tag-key = "${var.project_name}-${var.env}-k8s-ebs-csi-policy"
  }
}

data "aws_iam_policy_document" "eks_cluster_ebs_csi_policy" {
  statement {
    actions = ["sts:AssumeRoleWithWebIdentity"]
    effect  = "Allow"
    principals {
      type        = "Federated"
      identifiers = [aws_iam_openid_connect_provider.cluster_iodc_provider.arn]
    }
    condition {
      test     = "StringEquals"
      variable = "${local.eks_cluster_openid_provider_arn}:sub"
      values   = ["system:serviceaccount:kube-system:ebs-csi-controller-sa"]
    }
  }
  version = "2012-10-17"
}

resource "aws_iam_role" "eks_cluster_ebs_csi_role" {
  name               = "${var.project_name}-${var.env}-k8s-ebs-csi-role"
  assume_role_policy = data.aws_iam_policy_document.eks_cluster_ebs_csi_policy.json
  
  tags = {
    tag-key = "${var.project_name}-${var.env}-k8s-ebs-csi-role"
  }
}

resource "aws_iam_role_policy_attachment" "eks_cluster_ebs_csi_role_policy_attach" {
  policy_arn = aws_iam_policy.eks_cluster_ebs_csi_iam_policy.arn
  role       = aws_iam_role.eks_cluster_ebs_csi_role.name
}