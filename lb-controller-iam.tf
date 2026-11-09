resource "aws_iam_policy" "lb_controller" {
  name = "${local.project_name}-lb-controller"

  policy = file("${path.module}/policies/load-balancer-controller.json")

  tags = {
    Project = local.project_name
  }
}

resource "aws_iam_role" "lb_controller" {
  name = "${local.project_name}-internal-lb-controller"

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
            "aws:RequestTag/eks-cluster-arn"            = aws_eks_cluster.internal.arn
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

resource "aws_iam_role_policy_attachment" "lb_controller" {
  role       = aws_iam_role.lb_controller.name
  policy_arn = aws_iam_policy.lb_controller.arn
}

resource "aws_eks_pod_identity_association" "lb_controller" {
  cluster_name    = aws_eks_cluster.internal.name
  namespace       = "kube-system"
  service_account = "aws-load-balancer-controller"
  role_arn        = aws_iam_role.lb_controller.arn

  depends_on = [
    aws_eks_addon.pod_identity_agent,
    aws_iam_role_policy_attachment.lb_controller,
  ]
}