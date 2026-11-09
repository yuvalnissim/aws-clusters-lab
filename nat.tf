resource "aws_eip" "nat" {
  domain = "vpc"

  tags = {
    Name    = "${local.project_name}-nat-ip"
    Project = local.project_name
  }
}

resource "aws_nat_gateway" "lab" {
  allocation_id     = aws_eip.nat.id
  subnet_id         = aws_subnet.lab["public_a"].id
  connectivity_type = "public"

  depends_on = [
    aws_internet_gateway.lab,
    aws_route.public_internet,
    aws_route_table_association.public
  ]

  tags = {
    Name    = "${local.project_name}-nat"
    Project = local.project_name
  }
}

resource "aws_route" "private_internet" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.lab.id
}