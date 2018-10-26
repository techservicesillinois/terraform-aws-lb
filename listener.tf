locals {
  ports = "${concat(var.ports, var.secure_ports)}"
}

resource "aws_lb_listener" "default" {
  count             = "${length(local.ports)}"
  load_balancer_arn = "${element(concat(aws_lb.default.*.arn, aws_lb.user.*.arn), 0)}"
  port              = "${lookup(local.ports[count.index], "port")}"
  protocol          = "${lookup(local.ports[count.index], "protocol")}"
  ssl_policy        = "${lookup(local.ports[count.index], "protocol") == "HTTPS" ? lookup(local.ports[count.index], "ssl_policy", var.ssl_policy) : ""}"
  certificate_arn   = "${lookup(local.ports[count.index], "protocol") == "HTTPS" ? lookup(local.ports[count.index], "certificate_arn", var.certificate_arn) : ""}"

  default_action {
    target_group_arn = "${aws_lb_target_group.default.arn}"
    type             = "forward"
  }
}
