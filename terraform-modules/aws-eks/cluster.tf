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
    Name = "${var.project_name}-${var.env}"
  }
}