resource "aws_eks_node_group" "internal" {
  cluster_name    = aws_eks_cluster.internal.name
  node_group_name = "${local.project_name}-internal-workers"
  node_role_arn   = aws_iam_role.eks_nodes.arn

  version        = aws_eks_cluster.internal.version
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
    aws_iam_role_policy_attachment.eks_nodes_worker,
    aws_iam_role_policy_attachment.eks_nodes_images,
    aws_iam_role_policy_attachment.eks_nodes_cni,
    aws_route.private_internet,
  ]

  tags = {
    Project = local.project_name
  }
}