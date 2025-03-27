data "aws_region" "current" {}

data "aws_caller_identity" "current" {}

# FIXME: Replace reference to branch with reference to tagged version.

module "get-subnets" {
  source = "github.com/techservicesillinois/terraform-aws-util//modules/get-subnets?ref=v3.0.5"

  subnet_type = var.subnet_type
  vpc         = var.vpc
}

data "aws_vpc" "selected" {
  tags = {
    Name = var.vpc
  }
}

data "aws_route53_zone" "selected" {
  count = length(var.alias)

  name   = var.alias[count.index]["domain"]
  vpc_id = var.internal ? module.get-subnets.vpc.id : null
}
