output "cluster_id" {
  description = "EKS cluster ID"
  value       = aws_eks_cluster.main.id
}

output "cluster_arn" {
  description = "EKS cluster ARN"
  value       = aws_eks_cluster.main.arn
}

output "cluster_endpoint" {
  description = "EKS cluster endpoint"
  value       = aws_eks_cluster.main.endpoint
}

output "cluster_certificate_authority_data" {
  description = "EKS cluster certificate authority data"
  value       = aws_eks_cluster.main.certificate_authority[0].data
}

output "cluster_security_group_id" {
  description = "EKS cluster security group ID"
  value       = aws_eks_cluster.main.vpc_config[0].cluster_security_group_id
}

output "cluster_oidc_issuer_url" {
  description = "EKS cluster OIDC issuer URL"
  value       = aws_eks_cluster.main.identity[0].oidc[0].issuer
}

output "node_security_group_id" {
  description = "EKS node security group ID"
  value       = aws_security_group.node_group.id
}

output "kms_key_arn" {
  description = "KMS key ARN used for envelope encryption"
  value       = aws_kms_key.eks.arn
}

output "managed_node_groups" {
  description = "Map of managed node group outputs"
  value = {
    for name, group in aws_eks_node_group.managed :
    name => {
      node_group_arn  = group.arn
      node_group_id   = group.id
      status          = group.status
      version         = group.version
      capacity_type   = group.capacity_type
      instance_types  = group.instance_types
      desired_size    = group.scaling_config[0].desired_size
      max_size        = group.scaling_config[0].max_size
      min_size        = group.scaling_config[0].min_size
    }
  }
}