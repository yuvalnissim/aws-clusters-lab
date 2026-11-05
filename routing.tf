resource "aws_internet_gateway" "lab" {
  vpc_id = aws_vpc.lab.id

  tags = {
    Name    = "${local.project_name}-igw"
    Project = local.project_name
  }
}

resource "aws_route_table" "public" {
  vpc_id = aws_vpc.lab.id

  tags = {
    Name    = "${local.project_name}-public"
    Project = local.project_name
  }
}

resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.lab.id
}

resource "aws_route_table" "private" {
  vpc_id = aws_vpc.lab.id

  tags = {
    Name    = "${local.project_name}-private"
    Project = local.project_name
  }
}

resource "aws_route_table_association" "public" {
  for_each = toset(["public_a", "public_b"])

  subnet_id      = aws_subnet.lab[each.key].id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "private" {
  for_each = toset(["private_a", "private_b"])

  subnet_id      = aws_subnet.lab[each.key].id
  route_table_id = aws_route_table.private.id
}