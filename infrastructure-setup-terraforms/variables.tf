# Root level variables - these are passed to modules
variable "aws_region" {
  description = "AWS region"
  type        = string
  default     = "us-east-1"
}

variable "project_name" {
  description = "Project name"
  type        = string
  default     = "devsecops-k8s-project"
}

variable "environment" {
  description = "Environment name"
  type        = string
  default     = "prod"
}

variable "vpc_cidr" {
  description = "VPC CIDR block"
  type        = string
  default     = "10.0.0.0/16"
}

variable "availability_zones" {
  description = "Availability zones"
  type        = list(string)
  default     = ["us-east-1a", "us-east-1b", "us-east-1c"]
}

variable "private_subnet_cidrs" {
  description = "Private subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.1.0/24", "10.0.2.0/24", "10.0.3.0/24"]
}

variable "public_subnet_cidrs" {
  description = "Public subnet CIDR blocks"
  type        = list(string)
  default     = ["10.0.101.0/24", "10.0.102.0/24", "10.0.103.0/24"]
}

variable "cluster_version" {
  description = "Kubernetes version"
  type        = string
  default     = "1.28"
}

variable "endpoint_private_access" {
  description = "Enable private access to EKS API"
  type        = bool
  default     = true
}

variable "endpoint_public_access" {
  description = "Enable public access to EKS API"
  type        = bool
  default     = false
}

variable "public_access_cidrs" {
  description = "CIDR blocks that can access EKS public endpoint"
  type        = list(string)
  default     = []
}

variable "enabled_cluster_log_types" {
  description = "EKS control plane logging types"
  type        = list(string)
  default     = ["api", "audit", "authenticator", "controllerManager", "scheduler"]
}

variable "managed_node_groups" {
  description = "Managed node groups configuration"
  type = map(object({
    capacity_type  = string
    instance_types = list(string)
    desired_size   = number
    max_size       = number
    min_size       = number
    disk_size      = number
    ec2_ssh_key    = string
  }))
  default = {
    main = {
      capacity_type  = "SPOT"
      instance_types = ["t3.small"]
      desired_size   = 2
      max_size       = 5
      min_size       = 1
      disk_size      = 10
      ec2_ssh_key    = "eks-node-group-keypair"
    }
  }
}

# variable "jump_server_allowed_ips" {
#   description = "IP addresses allowed to SSH to jump server"
#   type        = list(string)
#   default     = ["your-ip/32"]
# }