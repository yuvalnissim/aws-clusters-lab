resource "aws_eks_cluster" "internal" {
  name     = "${local.project_name}-internal"
  role_arn = aws_iam_role.eks_cluster.arn
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
    aws_iam_role_policy_attachment.eks_cluster,
  ]

  tags = {
    Project = local.project_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "eks_internal_from_runner" {
  security_group_id = aws_eks_cluster.internal.vpc_config[0].cluster_security_group_id

  description                  = "Allow runner to reach the private Kubernetes API"
  referenced_security_group_id = aws_security_group.runner.id
  ip_protocol                  = "tcp"
  from_port                    = 443
  to_port                      = 443
}

output "internal_cluster_name" {
  value = aws_eks_cluster.internal.name
}

output "internal_cluster_endpoint" {
  value = aws_eks_cluster.internal.endpoint
}