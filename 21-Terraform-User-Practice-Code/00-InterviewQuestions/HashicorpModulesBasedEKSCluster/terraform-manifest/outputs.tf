output "aws_eks_cluster_endpoint" {
  description = "Cluster endpoint for control plane of AWS EKS cluster."
  value       = module.aws-eks-cluster.cluster_endpoint
}

output "aws_eks_cluster_security_group_id" {
  description = "Security group ids attached to the cluster control plane."
  value       = module.aws-eks-cluster.cluster_security_group_id
}