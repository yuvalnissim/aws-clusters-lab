resource "aws_eks_addon" "pod_identity_agent" {
  cluster_name  = aws_eks_cluster.internal.name
  addon_name    = "eks-pod-identity-agent"
  addon_version = "v1.4.1-eksbuild.3"

  depends_on = [
    aws_eks_node_group.internal,
    aws_iam_role_policy_attachment.eks_nodes_worker,
  ]

  tags = {
    Project = local.project_name
  }
}