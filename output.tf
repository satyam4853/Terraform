output "cluster_name" {
  value = var.cluster_name
  
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "vpc_id" {
  value = module.eks.vpc_id
}