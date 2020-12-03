locals {
  security_groups = local.is_alb ? concat(var.security_groups, [aws_security_group.default[0].id]) : null
}

resource "aws_lb" "default" {
  count              = length(keys(var.access_logs)) == 0 ? 1 : 0
  name               = var.name
  internal           = var.internal
  security_groups    = local.security_groups
  subnets            = data.aws_subnet_ids.selected.ids
  idle_timeout       = var.idle_timeout
  load_balancer_type = var.load_balancer_type

  # FIXME: This needs to be addressed.
  # access_logs {
  #   bucket  = "log-${data.aws_region.current.name}-${data.aws_caller_identity.current.account_id}"
  #   prefix  = "lb"
  #   enabled = true
  # }

  tags = var.tags

  ip_address_type            = var.ip_address_type
  enable_deletion_protection = var.enable_deletion_protection
  enable_http2               = var.enable_http2
}

resource "aws_lb" "user" {
  count              = length(keys(var.access_logs)) != 0 ? 1 : 0
  name               = var.name
  internal           = var.internal
  security_groups    = local.security_groups
  subnets            = data.aws_subnet_ids.selected.ids
  idle_timeout       = var.idle_timeout
  load_balancer_type = var.load_balancer_type

  # FIXME: This needs to be addressed.
  dynamic "access_logs" {
    for_each = [var.access_logs]
    content {
      bucket  = lookup(access_logs.value, "bucket")
      enabled = lookup(access_logs.value, "enabled", false)
      prefix  = lookup(access_logs.value, "prefix", null)
    }
  }

  tags = var.tags

  ip_address_type            = var.ip_address_type
  enable_deletion_protection = var.enable_deletion_protection
  enable_http2               = var.enable_http2
}
