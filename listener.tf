resource "aws_lb_listener" "default" {
  for_each          = var.ports
  load_balancer_arn = element(concat(aws_lb.default.*.arn, aws_lb.user.*.arn), 0)
  port              = each.key
  protocol          = each.value.protocol
  ssl_policy        = local.is_alb ? (each.value.protocol == "HTTPS" ? lookup(each.value, "ssl_policy", var.ssl_policy) : null) : null
  # FIXME: Original code is shown in the following line.
  # certificate_arn   = local.is_alb ? (each.value.protocol == "HTTPS" ? lookup(each.value, "certificate_arn", var.certificate_arn) : null) : null
  # TODO: Need to remove key for certificate_arn in documentation and code.
  certificate_arn = local.is_alb ? (each.value.protocol == "HTTPS" ? module.certificate.arn : null) : null

  default_action {
    target_group_arn = aws_lb_target_group.default.arn
    type             = "forward"
  }
}
