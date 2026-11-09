resource "aws_iam_role_policy" "runner_describe_internal" {
  name = "${local.project_name}-describe-internal"
  role = aws_iam_role.runner.id

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = "eks:DescribeCluster"
        Resource = aws_eks_cluster.internal.arn
      }
    ]
  })
}

resource "aws_eks_access_entry" "runner_internal" {
  cluster_name  = aws_eks_cluster.internal.name
  principal_arn = aws_iam_role.runner.arn
  type          = "STANDARD"
}

resource "aws_eks_access_policy_association" "runner_internal_view" {
  cluster_name  = aws_eks_cluster.internal.name
  principal_arn = aws_eks_access_entry.runner_internal.principal_arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSViewPolicy"

  access_scope {
    type = "cluster"
  }
}

resource "aws_eks_access_policy_association" "runner_internal_deploy" {
  cluster_name  = aws_eks_cluster.internal.name
  principal_arn = aws_eks_access_entry.runner_internal.principal_arn

  policy_arn = "arn:aws:eks::aws:cluster-access-policy/AmazonEKSEditPolicy"

  access_scope {
    type       = "namespace"
    namespaces = ["default"]
  }
}