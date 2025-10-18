# EKS Cluster
resource "aws_eks_cluster" "main" {
  name     = var.cluster_name
  version  = var.cluster_version
  role_arn = aws_iam_role.cluster.arn

  vpc_config {
    subnet_ids              = var.private_subnet_ids
    endpoint_private_access = var.endpoint_private_access
    endpoint_public_access  = var.endpoint_public_access
    public_access_cidrs     = var.public_access_cidrs
  }

  enabled_cluster_log_types = var.enabled_cluster_log_types

  encryption_config {
    resources = ["secrets"]
    provider {
      key_arn = aws_kms_key.eks.arn
    }
  }

  depends_on = [
    aws_iam_role_policy_attachment.cluster_AmazonEKSClusterPolicy,
    aws_iam_role_policy_attachment.cluster_AmazonEKSVPCResourceController,
  ]

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# EKS Cluster IAM Role
resource "aws_iam_role" "cluster" {
  name_prefix = "${var.cluster_name}-cluster"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSClusterPolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
  role       = aws_iam_role.cluster.name
}

resource "aws_iam_role_policy_attachment" "cluster_AmazonEKSVPCResourceController" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSVPCResourceController"
  role       = aws_iam_role.cluster.name
}

# EKS KMS Key for envelope encryption
resource "aws_kms_key" "eks" {
  description             = "EKS Secret Encryption Key"
  deletion_window_in_days = 7
  enable_key_rotation     = true

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# IAM Policy for EKS Admin Access
resource "aws_iam_policy" "eks_admin_view" {
  name_prefix = "${var.cluster_name}-eks-admin-view"
  description = "Policy for EKS admin view access"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:ListFargateProfiles",
          "eks:ListNodegroups",
          "eks:ListUpdates",
          "eks:AccessKubernetesApi",
          "eks:DescribeAddon",
          "eks:ListAddons"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_policy" "eks_admin_cluster" {
  name_prefix = "${var.cluster_name}-eks-admin-cluster"
  description = "Policy for EKS admin cluster access"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:*"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "eks.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "eks_admin" {
  name_prefix = "${var.cluster_name}-eks-admin"
  description = "Policy for EKS admin access"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:*",
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:CreateCluster",
          "eks:DeleteCluster",
          "eks:UpdateClusterVersion",
          "eks:UpdateClusterConfig",
          "eks:CreateNodegroup",
          "eks:DeleteNodegroup",
          "eks:UpdateNodegroupConfig",
          "eks:UpdateNodegroupVersion",
          "eks:AssociateEncryptionConfig",
          "eks:AssociateIdentityProviderConfig",
          "eks:DisassociateIdentityProviderConfig",
          "eks:ListFargateProfiles",
          "eks:CreateFargateProfile",
          "eks:DeleteFargateProfile",
          "eks:ListNodegroups",
          "eks:ListUpdates",
          "eks:AccessKubernetesApi",
          "eks:DescribeAddon",
          "eks:ListAddons",
          "eks:CreateAddon",
          "eks:DeleteAddon",
          "eks:UpdateAddon",
          "eks:DescribeIdentityProviderConfig",
          "eks:ListIdentityProviderConfigs"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = "iam:PassRole"
        Resource = "*"
        Condition = {
          StringEquals = {
            "iam:PassedToService" = "eks.amazonaws.com"
          }
        }
      }
    ]
  })
}

resource "aws_iam_policy" "eks_view" {
  name_prefix = "${var.cluster_name}-eks-view"
  description = "Policy for EKS view-only access"
  
  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "eks:DescribeCluster",
          "eks:ListClusters",
          "eks:ListFargateProfiles",
          "eks:ListNodegroups",
          "eks:ListUpdates",
          "eks:AccessKubernetesApi",
          "eks:DescribeAddon",
          "eks:ListAddons",
          "eks:DescribeIdentityProviderConfig",
          "eks:ListIdentityProviderConfigs",
          "eks:DescribeNodegroup",
          "eks:DescribeFargateProfile"
        ]
        Resource = "*"
      }
    ]
  })
}



# Attach this policies to your jump server role 
resource "aws_iam_role_policy_attachment" "jump_server_eks_admin_view" {
  role       = "Admin-Access-Role-For-Jump-Server-EKS" 
  policy_arn = aws_iam_policy.eks_admin_view.arn
}

resource "aws_iam_role_policy_attachment" "jump_server_eks_admin_cluster" {
  role       = "Admin-Access-Role-For-Jump-Server-EKS"  
  policy_arn = aws_iam_policy.eks_admin_cluster.arn
}

resource "aws_iam_role_policy_attachment" "jump_server_eks_admin" {
  role       = "Admin-Access-Role-For-Jump-Server-EKS"
  policy_arn = aws_iam_policy.eks_admin.arn
}

resource "aws_iam_role_policy_attachment" "jump_server_eks_view" {
  role       = "Admin-Access-Role-For-Jump-Server-EKS"
  policy_arn = aws_iam_policy.eks_view.arn
}

# Managed Node Groups
resource "aws_eks_node_group" "managed" {
  for_each = var.managed_node_groups

  cluster_name    = aws_eks_cluster.main.name
  node_group_name = each.key
  node_role_arn   = aws_iam_role.nodes.arn
  subnet_ids      = var.private_subnet_ids

  capacity_type  = each.value.capacity_type
  instance_types = each.value.instance_types

  scaling_config {
    desired_size = each.value.desired_size
    max_size     = each.value.max_size
    min_size     = each.value.min_size
  }

  update_config {
    max_unavailable = 1
  }

  # Ensure these are properly sized for your workload
  disk_size = each.value.disk_size

  remote_access {
    ec2_ssh_key               = each.value.ec2_ssh_key
    source_security_group_ids = [aws_security_group.node_group.id]
  }

  depends_on = [
    aws_iam_role_policy_attachment.nodes_AmazonEKSWorkerNodePolicy,
    aws_iam_role_policy_attachment.nodes_AmazonEKS_CNI_Policy,
    aws_iam_role_policy_attachment.nodes_AmazonEC2ContainerRegistryReadOnly,
  ]

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}

# Node Group IAM Role
resource "aws_iam_role" "nodes" {
  name_prefix = "${var.cluster_name}-nodes"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Action = "sts:AssumeRole"
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
      }
    ]
  })

  tags = {
    Environment = var.environment
    Project     = var.project_name
  }
}



resource "aws_iam_role_policy_attachment" "nodes_AmazonEKSWorkerNodePolicy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSWorkerNodePolicy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes_AmazonEKS_CNI_Policy" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKS_CNI_Policy"
  role       = aws_iam_role.nodes.name
}

resource "aws_iam_role_policy_attachment" "nodes_AmazonEC2ContainerRegistryReadOnly" {
  policy_arn = "arn:aws:iam::aws:policy/AmazonEC2ContainerRegistryReadOnly"
  role       = aws_iam_role.nodes.name
}

# Node Group Security Group
resource "aws_security_group" "node_group" {
  name_prefix = "${var.cluster_name}-node-group-"
  description = "Security group for EKS node groups"
  vpc_id      = var.vpc_id

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name        = "${var.cluster_name}-node-group-sg"
    Environment = var.environment
    Project     = var.project_name
  }
}