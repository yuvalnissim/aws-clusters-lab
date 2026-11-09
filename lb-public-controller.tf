resource "aws_eks_addon" "public_pod_identity_agent" {
  cluster_name  = aws_eks_cluster.public.name
  addon_name    = "eks-pod-identity-agent"
  addon_version = "v1.4.1-eksbuild.3"

  depends_on = [
    aws_eks_node_group.public,
  ]

  tags = {
    Project = local.project_name
  }
}

resource "aws_iam_role" "public_lb_controller" {
  name = "${local.project_name}-public-lb-controller"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Principal = {
          Service = "pods.eks.amazonaws.com"
        }
        Action = [
          "sts:AssumeRole",
          "sts:TagSession",
        ]
        Condition = {
          StringEquals = {
            "aws:RequestTag/eks-cluster-arn"            = aws_eks_cluster.public.arn
            "aws:RequestTag/kubernetes-namespace"       = "kube-system"
            "aws:RequestTag/kubernetes-service-account" = "aws-load-balancer-controller"
          }
        }
      }
    ]
  })

  tags = {
    Project = local.project_name
  }
}

resource "aws_iam_role_policy_attachment" "public_lb_controller" {
  role       = aws_iam_role.public_lb_controller.name
  policy_arn = aws_iam_policy.lb_controller.arn
}

resource "aws_eks_pod_identity_association" "public_lb_controller" {
  cluster_name    = aws_eks_cluster.public.name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.public_lb_controller.arn

  depends_on = [
    aws_eks_addon.public_pod_identity_agent,
    aws_iam_role_policy_attachment.public_lb_controller,
  ]
}