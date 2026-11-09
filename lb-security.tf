resource "aws_security_group" "internal_alb" {
  name_prefix = "${local.project_name}-internal-alb-"
  description = "Security group for the internal application load balancer"
  vpc_id      = aws_vpc.lab.id

  tags = {
    Name    = "${local.project_name}-internal-alb"
    Project = local.project_name
  }
}

resource "aws_vpc_security_group_ingress_rule" "internal_alb_from_runner" {
  security_group_id            = aws_security_group.internal_alb.id
  referenced_security_group_id = aws_security_group.runner.id

  description = "Allow HTTP from the runner"
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "runner_to_internal_alb" {
  security_group_id            = aws_security_group.runner.id
  referenced_security_group_id = aws_security_group.internal_alb.id

  description = "Allow HTTP to the internal ALB"
  ip_protocol = "tcp"
  from_port   = 80
  to_port     = 80
}

resource "aws_vpc_security_group_egress_rule" "internal_alb_to_app" {
  security_group_id = aws_security_group.internal_alb.id

  description = "Allow application traffic within the VPC"
  ip_protocol = "tcp"
  from_port   = 8080
  to_port     = 8080
  cidr_ipv4   = aws_vpc.lab.cidr_block
}

output "internal_alb_security_group_id" {
  value = aws_security_group.internal_alb.id
}