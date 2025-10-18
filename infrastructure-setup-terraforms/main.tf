# Get current AWS region
data "aws_region" "current" {}

# Get current AWS caller identity
data "aws_caller_identity" "current" {}

# VPC Module
module "vpc" {
  source = "./modules/vpc"

  # Pass variables from root to VPC module
  project_name          = var.project_name
  environment           = var.environment
  vpc_cidr             = var.vpc_cidr
  availability_zones   = var.availability_zones
  private_subnet_cidrs = var.private_subnet_cidrs
  public_subnet_cidrs  = var.public_subnet_cidrs
}

# EKS Cluster Module
module "eks" {
  source = "./modules/eks"

  # So i will pass my variables from root to EKS module for reusibility
  project_name          = var.project_name
  environment           = var.environment
  cluster_name          = "${var.project_name}-${var.environment}"
  cluster_version       = var.cluster_version
  
  vpc_id                = module.vpc.vpc_id
  private_subnet_ids    = module.vpc.private_subnet_ids
  public_subnet_ids     = module.vpc.public_subnet_ids
  
  endpoint_private_access = var.endpoint_private_access
  endpoint_public_access  = var.endpoint_public_access
  public_access_cidrs     = var.public_access_cidrs
  
  enabled_cluster_log_types = var.enabled_cluster_log_types
  
  managed_node_groups = var.managed_node_groups
}
