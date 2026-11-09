locals {
  project_name = "aws-clusters-lab"

  subnets = {
    public_a = {
      cidr = "10.20.1.0/24"
      az   = "eu-north-1a"
    }
    public_b = {
      cidr = "10.20.2.0/24"
      az   = "eu-north-1b"
    }
    private_a = {
      cidr = "10.20.11.0/24"
      az   = "eu-north-1a"
    }
    private_b = {
      cidr = "10.20.12.0/24"
      az   = "eu-north-1b"
    }
  }
}

resource "aws_vpc" "lab" {
  cidr_block           = "10.20.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name    = "${local.project_name}-vpc"
    Project = local.project_name
  }
}

resource "aws_subnet" "lab" {
  for_each = local.subnets

  vpc_id                  = aws_vpc.lab.id
  cidr_block              = each.value.cidr
  availability_zone       = each.value.az
  map_public_ip_on_launch = false

  tags = merge(
    {
      Name    = "${local.project_name}-${each.key}"
      Project = local.project_name
    },
    startswith(each.key, "private_") ? {
      "kubernetes.io/role/internal-elb" = "1"
      } : {
      "kubernetes.io/role/elb" = "1"
    }
  )
}

output "vpc_id" {
  value = aws_vpc.lab.id
}

output "subnet_ids" {
  value = {
    for name, subnet in aws_subnet.lab : name => subnet.id
  }
}