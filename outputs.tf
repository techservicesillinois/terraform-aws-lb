output "fqdn" {
  value = aws_route53_record.default.*.fqdn
}

output "id" {
  description = "The ARN of the load balancer (matches arn)"
  value       = element(concat(aws_lb.default.*.id, aws_lb.user.*.id), 0)
}

output "arn" {
  description = "The ARN of the load balancer (matches id)."
  value       = element(concat(aws_lb.default.*.arn, aws_lb.user.*.arn), 0)
}

output "arn_suffix" {
  description = "The ARN suffix for use with CloudWatch Metrics."
  value = element(
    concat(aws_lb.default.*.arn_suffix, aws_lb.user.*.arn_suffix),
    0,
  )
}

output "dns_name" {
  description = "The DNS name of the load balancer."
  value       = element(concat(aws_lb.default.*.dns_name, aws_lb.user.*.dns_name), 0)
}

# TODO: Need to figure out why this does not work
#output "canonical_hosted_zone_id" {
#  description = "The canonical hosted zone ID of the load balancer."
#  value       = "${element(concat(aws_lb.default.*.canonical_hosted_zone_id, aws_lb.user.*.canonical_hosted_zone_id), 0)}"
#}

output "zone_id" {
  description = "The canonical hosted zone ID of the load balancer (to be used in a Route 53 Alias record)."
  value       = element(concat(aws_lb.default.*.zone_id, aws_lb.user.*.zone_id), 0)
}

output "listener_arns" {
  description = "A list of all the listener ARNs created."
  value       = aws_lb_listener.default.*.arn
}

output "security_group_id" {
  description = "Default security group created for the load balancer."
  value       = aws_security_group.default.id
}

output "target_group_arn" {
  description = "Default target group for all created listeners."
  value       = aws_lb_target_group.default.arn
}
