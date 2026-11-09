resource "aws_iam_role" "eks_public_nodes" {
  name = "${local.project_name}-public-eks-nodes"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "ec2.amazonaws.com"
        }
        Action = "sts:AssumeRole"
      }
    ]
  })

  tags = {
    Project = local.project_name
  }
}

resource "aws_iam_role_policy_attachment" "eks_public_nodes" {
  for_each = toset([
    "AmazonEKSWorkerNodePolicy",
    "AmazonEC2ContainerRegistryPullOnly",
    "AmazonEKS_CNI_Policy",
  ])

  role       = aws_iam_role.eks_public_nodes.name
  policy_arn = "arn:aws:iam::aws:policy/${each.value}"
}

resource "aws_eks_node_group" "public" {
  cluster_name    = aws_eks_cluster.public.name
  node_group_name = "${local.project_name}-public-workers"
  node_role_arn   = aws_iam_role.eks_public_nodes.arn

  version        = aws_eks_cluster.public.version
  ami_type       = "AL2023_x86_64_STANDARD"
  instance_types = ["t3.small"]
  capacity_type  = "ON_DEMAND"
  disk_size      = 20

  subnet_ids = [
    aws_subnet.lab["private_a"].id,
    aws_subnet.lab["private_b"].id,
  ]

  scaling_config {
    desired_size = 2
    min_size     = 2
    max_size     = 3
  }

  update_config {
    max_unavailable = 1
  }

  depends_on = [
    aws_iam_role_policy_attachment.eks_public_nodes,
    aws_route.private_internet,
  ]

  tags = {
    Project = local.project_name
  }
}