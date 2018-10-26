resource "aws_lb" "default" {
  count           = "${length(keys(var.access_logs)) == 0 ? 1 : 0}"
  name            = "${var.name}"
  internal        = "${var.internal}"
  security_groups = ["${concat(var.security_groups, list(aws_security_group.default.id))}"]
  subnets         = ["${data.aws_subnet_ids.selected.ids}"]
  idle_timeout    = "${var.idle_timeout}"

  access_logs {
    bucket  = "log-${data.aws_region.current.name}-${data.aws_caller_identity.current.account_id}"
    prefix  = "lb"
    enabled = "true"
  }

  tags = "${var.tags}"

  ip_address_type            = "${var.ip_address_type}"
  enable_deletion_protection = "${var.enable_deletion_protection}"
  enable_http2               = "${var.enable_http2}"
}

resource "aws_lb" "user" {
  count           = "${length(keys(var.access_logs)) != 0 ? 1 : 0}"
  name            = "${var.name}"
  internal        = "${var.internal}"
  security_groups = ["${concat(var.security_groups, list(aws_security_group.default.id))}"]
  subnets         = ["${data.aws_subnet_ids.selected.ids}"]
  idle_timeout    = "${var.idle_timeout}"

  access_logs = ["${var.access_logs}"]

  tags = "${var.tags}"

  ip_address_type            = "${var.ip_address_type}"
  enable_deletion_protection = "${var.enable_deletion_protection}"
  enable_http2               = "${var.enable_http2}"
}
