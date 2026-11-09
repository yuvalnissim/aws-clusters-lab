resource "aws_iam_role" "eks_public_cluster" {
  name = "${local.project_name}-public-eks-cluster"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "eks.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project = local.project_name
  }
}

resource "aws_iam_role_policy_attachment" "eks_public_cluster" {
  role       = aws_iam_role.eks_public_cluster.name
  policy_arn = "arn:aws:iam::aws:policy/AmazonEKSClusterPolicy"
}

resource "aws_eks_cluster" "public" {
  name     = "${local.project_name}-public"
  role_arn = aws_iam_role.eks_public_cluster.arn
  version  = "1.37"

  access_config {
    authentication_mode                         = "API"
    bootstrap_cluster_creator_admin_permissions = false
  }

  vpc_config {
    subnet_ids = [
      aws_subnet.lab["private_a"].id,
      aws_subnet.lab["private_b"].id,
    ]

    endpoint_private_access = true
    endpoint_public_access  = false
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_public_cluster,
  ]

  tags = {
    Project = local.project_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "eks_public_from_runner" {
  security_group_id = aws_eks_cluster.public.vpc_config[0].cluster_security_group_id

  description                  = "Allow runner to reach the private Kubernetes API"
  referenced_security_group_id = aws_security_group.runner.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
}

output "public_cluster_name" {
  value = aws_eks_cluster.public.name
}

output "public_cluster_endpoint" {
  value = aws_eks_cluster.public.endpoint
}