data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

data "aws_vpc" "selected" {
  tags = {
    Name = var.vpc
  }
}

data "aws_subnet_ids" "selected" {
  vpc_id = data.aws_vpc.selected.id

  tags = {
    Tier = var.tier
  }
}

data "aws_route53_zone" "selected" {
  count = length(var.alias)

  name   = var.alias[count.index]["domain"]
  vpc_id = var.internal ? data.aws_vpc.selected.id : null
}
