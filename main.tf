# TODO: We currently support only application and network. This needs to be
# documented and validated.

locals {
  security_groups = local.is_alb ? concat(var.security_groups, [aws_security_group.default[0].id]) : null
}

resource "aws_lb" "default" {
  name               = var.name
  internal           = var.internal
  security_groups    = local.security_groups
  subnets            = data.aws_subnet_ids.selected.ids
  idle_timeout       = var.idle_timeout
  load_balancer_type = var.load_balancer_type

  # FIXME: This needs to be reviewed.
  dynamic "access_logs" {
  # for_each = [var.access_logs]
    for_each = var.access_logs
    content {
      bucket  = lookup(each.value, "bucket")
      enabled = lookup(each.value, "enabled", false)
      prefix  = lookup(each.value, "prefix", null)
    }
  }

  # FIXME: Need to address the case wherein var.access_logs is empty.
  #
  # access_logs {
  #   bucket  = "log-${data.aws_region.current.name}-${data.aws_caller_identity.current.account_id}"
  #   prefix  = "lb"
  #   enabled = true
  # }

  ip_address_type            = var.ip_address_type
  enable_deletion_protection = var.enable_deletion_protection
  enable_http2               = var.enable_http2

  tags = var.tags
}
