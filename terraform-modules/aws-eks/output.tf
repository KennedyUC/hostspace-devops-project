output "cluster_endpoint" {
    value       = aws_eks_cluster.eks_cluster.endpoint
    description = "EKS cluster api endpoint"
}

output "cluster_certificate_authority_data" {
    value       = aws_eks_cluster.eks_cluster.certificate_authority[0].data
    description = "EKS cluster Certificate Authority Data"
}