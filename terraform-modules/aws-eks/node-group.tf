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

resource "aws_eks_node_group" "eks_nodes" {
  cluster_name    = aws_eks_cluster.eks_cluster.name
  version         = var.k8s_version
  node_group_name = "${var.project_name}-${var.env}-grp"
  node_role_arn   = aws_iam_role.EKSNodeGroupRole.arn
  subnet_ids      = var.private_subnet_ids
  instance_types  = [var.instance_type]
  scaling_config {
    desired_size = var.desired_node_count
    min_size     = var.min_node_count
    max_size     = var.max_node_count
  }

  capacity_type  = var.capacity_type
  ami_type       = var.ami_type
  disk_size      = var.node_disk_size

  depends_on = [
    aws_iam_role_policy_attachment.AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.AmazonEC2ContainerRegistryReadOnly,
    aws_iam_role_policy_attachment.AmazonEKS_CNI_Policy
  ]

  tags = {
    Name = "${var.project_name}-${var.env}"
  }
}

locals {
  cluster_name = aws_eks_cluster.eks_cluster.name
}

resource "null_resource" "kubectl_config" {
  count = var.enable_powershell_interpreter ? 0 : 1
  provisioner "local-exec" {
    command = <<-EOT
                aws configure set aws_access_key_id $access_key
                aws configure set aws_secret_access_key $secret_key
                aws configure set default.region $region
                aws configure set default.output json

                aws eks --region $region update-kubeconfig --name $cluster_name

                kubectl get nodes
                kubectl delete sc gp2
              EOT

    environment = {
      access_key    = var.user_access_key
      secret_key    = var.user_secret_key
      cluster_name  = local.cluster_name
      region        = var.aws_region
    }
  }

  depends_on = [
    aws_eks_node_group.eks_nodes
  ]
}

resource "null_resource" "kubectl_config_powershell" {
  count = var.enable_powershell_interpreter ? 1 : 0

  provisioner "local-exec" {
    interpreter = ["Powershell", "-Command"]
    command = <<-EOT
                aws configure set aws_access_key_id $Env:access_key
                aws configure set aws_secret_access_key $Env:secret_key
                aws configure set default.region $Env:region
                aws configure set default.output json

                aws eks --region $Env:region update-kubeconfig --name $Env:cluster_name

                kubectl get nodes
              EOT

    environment = {
      access_key    = var.user_access_key
      secret_key    = var.user_secret_key
      cluster_name  = local.cluster_name
      region        = var.aws_region
    }
  }

  depends_on = [
    aws_eks_node_group.eks_nodes
  ]
}