#
# Recommended security groups 
#
#    https://docs.aws.amazon.com/elasticloadbalancing/latest/application/load-balancer-update-security-groups.html

resource "aws_security_group" "default" {
  description = format("LB %s security group", var.name)
  name        = var.name
  vpc_id      = module.get-subnets.vpc.id
  tags        = merge({ Name = var.name }, var.tags)
}

resource "aws_security_group" "secure" {
  count = length(var.secure_ports)

  description = lookup(
    var.secure_ports[count.index],
    "security_group_description",
    "",
  )
  name   = var.secure_ports[count.index]["security_group"]
  vpc_id = module.get-subnets.vpc.id
  tags   = merge({ Name = var.name }, var.tags)
}

# Allow inbound TCP connections on listener port only.

resource "aws_security_group_rule" "internet_in" {
  # Should be activated if internal is FALSE.
  count = var.internal ? 0 : length(var.ports)

  description       = format("Allow inbound TCP traffic to LB port %d", var.ports[count.index]["port"])
  type              = "ingress"
  from_port         = var.ports[count.index]["port"]
  to_port           = var.ports[count.index]["port"]
  protocol          = "tcp"
  cidr_blocks       = ["0.0.0.0/0"]
  security_group_id = aws_security_group.default.id
}

resource "aws_security_group_rule" "vpc_in" {
  # Should be activated if internal is TRUE.
  count = var.internal ? length(var.ports) : 0

  description       = format("Allow inbound TCP traffic to LB port %d from VPC", var.ports[count.index]["port"])
  type              = "ingress"
  from_port         = var.ports[count.index]["port"]
  to_port           = var.ports[count.index]["port"]
  protocol          = "tcp"
  cidr_blocks       = [module.get-subnets.vpc.cidr_block]
  security_group_id = aws_security_group.default.id
}

# Resource to support application specific ports on the internal load balancer
# that are protected by custom security groups so that we can limit access to certain applications

resource "aws_security_group_rule" "port_in" {
  # Should be activated if security_group_ports has a port.
  count = length(var.secure_ports)

  description              = format("Allow inbound TCP traffic to LB port %d from %s security group", var.secure_ports[count.index]["port"], aws_security_group.default.name)
  type                     = "ingress"
  source_security_group_id = element(aws_security_group.secure.*.id, count.index)
  from_port                = var.secure_ports[count.index]["port"]
  to_port                  = var.secure_ports[count.index]["port"]
  protocol                 = "tcp"
  security_group_id        = aws_security_group.default.id
}

# Allows all inbound ICMP to support ping, traceroute, and most importantly Path MTU Discovery
# https://docs.aws.amazon.com/AWSCloudFormation/latest/UserGuide/aws-properties-ec2-security-group-ingress.html
# https://www.iana.org/assignments/icmp-parameters/icmp-parameters.xhtml
resource "aws_security_group_rule" "allow_icmp" {
  description = "Allow inbound ICMP traffic"

  type        = "ingress"
  from_port   = -1 # Allow any ICMP type number
  to_port     = -1 # Allow any ICMP code
  protocol    = "icmp"
  cidr_blocks = ["0.0.0.0/0"]

  security_group_id = aws_security_group.default.id
}
