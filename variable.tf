variable "region" {
  description = "AWS region to deploy the VPC and EKS cluster"
  type        = string
  default     = "ap-south-1"
  
}

variable "cluster_name" {
  description = "Name for the EKS cluster"
  type        = string
  default     = "banking-prod-eks"
}

variable "cidr_block" {
  description = "CIDR block for the VPC"
  type        = string
  default     = "10.0.0.0/16"
}