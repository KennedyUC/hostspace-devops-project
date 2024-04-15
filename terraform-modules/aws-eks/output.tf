output "cluster_endpoint" {
    value       = aws_eks_cluster.eks_cluster.endpoint
    description = "EKS cluster api endpoint"
}

output "cluster_certificate_authority_data" {
    value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
    description = "EKS cluster Certificate Authority Data"
}

output "eks_cluster_ebs_csi_iam_policy_arn" {
  value = aws_iam_policy.eks_cluster_ebs_csi_iam_policy.arn
}

output "ebs_csi_iam_role_arn" {
  description = "EBS CSI IAM Role ARN"
  value       = aws_iam_role.eks_cluster_ebs_csi_role.arn
}

output "cluster_ebs_addon_arn" {
  description = "Amazon Resource Name (ARN) of the EKS add-on"
  value       = aws_eks_addon.eks_cluster_ebs_csi_addon.arn
}
output "cluster_ebs_addon_id" {
  description = "EKS Cluster name and EKS Addon name"
  value       = aws_eks_addon.eks_cluster_ebs_csi_addon.id
}
output "cluster_ebs_addon_time" {
  description = "Date and time in RFC3339 format that the EKS add-on was created"
  value       = aws_eks_addon.eks_cluster_ebs_csi_addon.created_at
}

output "eks_thumbprint" {
    description = "EKS cluster thumbprint"
    value       = data.tls_certificate.eks_cluster.certificates[0].sha1_fingerprint
}