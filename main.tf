data "aws_caller_identity" "current" {}

data "aws_availability_zones" "available" {
  state = "available"
}

output "connected_account_id" {
  value = data.aws_caller_identity.current.account_id
}

output "available_zones" {
  value = data.aws_availability_zones.available.names
}