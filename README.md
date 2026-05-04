Project Structure

eks-terraform-project/
│
├── provider.tf
├── variables.tf
├── terraform.tfvars
├── vpc.tf
├── eks.tf
├── outputs.tf



---
##provider.tf

provider "aws" {
  region = var.region
}

terraform {
  required_version = ">= 1.3.0"

  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 5.0"
    }
  }
}

##variable.tf
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

##terraform.tfvars
region = "ap-south-1"
cluster_name = "banking-prod-eks"
cidr_block = "10.0.0.0/16"

##vpc
module  "vpc" {
  source = "terraform-aws-modules/vpc/aws"

  name = "my-vpc"
  cidr = var.cidr_block

  azs = ["${var.region}a", "${var.region}b"]

  private_subnets = ["10.0.1.0/24", "10.0.2.0/24"]
  public_subnets  = ["10.0.101.0/24", "10.0.102.0/24"]

  enable_nat_gateway = true
  single_nat_gateway = true
    tags = {
        Environment = "prod"
    }
}

##eks
module "eks" {
    source = "terraform-aws-modules/eks/aws"
    version = "20.0.0"
    cluster_name    = var.cluster_name
    cluster_version = "1.29"
    vpc_id             = module.vpc.vpc_id
    subnet_ids         = module.vpc.private_subnets

    enable_irsa = true

    eks_managed_node_groups = {
        default = {
            desired_size = 2
            max_size     = 3
            min_size     = 1

            instance_types = ["t3.medium"]
            capacity_type  = "ON_DEMAND"
        }
    }
tags = {
    Environment = "prod"
  }

  
}


##output.tf
output "cluster_name" {
  value = var.cluster_name
  
}

output "cluster_endpoint" {
  value = module.eks.cluster_endpoint
}

output "vpc_id" {
  value = module.eks.vpc_id
}


##commands
terraform init
terraform plan
terraform apply

######################################################
1. What provider does?
Connects Terraform to AWS
Handles authentication & API calls
2. Why modules?
Reusable
Production-ready
Saves time
3. Why private subnets for EKS?
Security (nodes not exposed to internet)
4. NAT Gateway purpose?
Allows private instances to access internet (for updates, pulling images)
5. Managed Node Group?
AWS manages EC2 lifecycle (scaling, updates)
