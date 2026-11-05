resource "aws_security_group" "runner" {
  name_prefix = "${local.project_name}-runner-"
  description = "Security group for the private deployment runner"
  vpc_id      = aws_vpc.lab.id

  tags = {
    Name    = "${local.project_name}-runner"
    Project = local.project_name
  }
}

resource "aws_vpc_security_group_egress_rule" "runner_https" {
  security_group_id = aws_security_group.runner.id

  description = "Allow outbound TCP 443"
  ip_protocol = "tcp"
  from_port   = 443
  to_port     = 443
  cidr_ipv4   = "0.0.0.0/0"
}

output "runner_security_group_id" {
  value = aws_security_group.runner.id
}