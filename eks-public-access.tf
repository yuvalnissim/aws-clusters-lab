resource "aws_iam_role_policy" "runner_describe_public" {
  name = "${local.project_name}-describe-public"
  role = aws_iam_role.runner.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "eks:DescribeCluster"
        Resource = aws_eks_cluster.public.arn
      }
    ]
  })
}

resource "aws_eks_access_entry" "runner_public" {
  cluster_name  = aws_eks_cluster.public.name
  principal_arn = aws_iam_role.runner.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "runner_public_view" {
  cluster_name  = aws_eks_cluster.public.name
  principal_arn = aws_eks_access_entry.runner_public.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_policy_association" "runner_public_deploy" {
  cluster_name  = aws_eks_cluster.public.name
  principal_arn = aws_eks_access_entry.runner_public.principal_arn
  policy_arn    = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"

  access_scope {
    type       = "namespace"
    namespaces = ["default"]
  }
}