data "aws_ssm_parameter" "amazon_linux" {
  name = "/aws/service/ami-amazon-linux-latest/al2023-ami-kernel-default-x86_64"
}

resource "aws_instance" "runner" {
  ami           = data.aws_ssm_parameter.amazon_linux.value
  instance_type = "t3.micro"

  subnet_id                   = aws_subnet.lab["private_a"].id
  associate_public_ip_address = false
  vpc_security_group_ids      = [aws_security_group.runner.id]
  iam_instance_profile        = aws_iam_instance_profile.runner.name

  metadata_options {
    http_endpoint               = "enabled"
    http_tokens                 = "required"
    http_put_response_hop_limit = 1
  }

  root_block_device {
    volume_type           = "gp3"
    volume_size           = 8
    encrypted             = true
    delete_on_termination = true
  }

  credit_specification {
    cpu_credits = "standard"
  }

  depends_on = [
    aws_route.private_internet,
    aws_iam_role_policy_attachment.runner_ssm,
    aws_vpc_security_group_egress_rule.runner_https
  ]

  tags = {
    Name    = "${local.project_name}-runner"
    Project = local.project_name
  }
}

output "runner_instance_id" {
  value = aws_instance.runner.id
}

output "runner_private_ip" {
  value = aws_instance.runner.private_ip
}