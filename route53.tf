resource "aws_route53_record" "default" {
  count = length(var.alias)

  zone_id = element(data.aws_route53_zone.selected.*.zone_id, count.index)
  name    = var.alias[count.index]["hostname"]
  type    = "A"

  alias {
    name                   = element(concat(aws_lb.default.*.dns_name, aws_lb.user.*.dns_name), 0)
    zone_id                = element(concat(aws_lb.default.*.zone_id, aws_lb.user.*.zone_id), 0)
    evaluate_target_health = true
  }
}
