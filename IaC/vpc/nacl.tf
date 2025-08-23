resource "aws_network_acl" "traderdeck_nacl" {
  vpc_id = aws_vpc.my_vpc.id

  tags = {
    Name = "TraderDeck-NACL"
  }
}

resource "aws_network_acl_rule" "allow_ssh_inbound" {
  network_acl_id = aws_network_acl.traderdeck_nacl.id
  rule_number    = 100
  egress         = false
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}

resource "aws_network_acl_rule" "allow_ephemeral_ports_outbound" {
  network_acl_id = aws_network_acl.traderdeck_nacl.id
  rule_number    = 130
  egress         = true
  protocol       = "-1"
  rule_action    = "allow"
  cidr_block     = "0.0.0.0/0"
  from_port      = 0
  to_port        = 0
}