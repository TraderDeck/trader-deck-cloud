resource "aws_vpc" "my_vpc" {
  cidr_block           = "10.16.0.0/16"
  enable_dns_support   = true
  enable_dns_hostnames = true

  tags = {
    Name = "trader-deck-vpc"
  }
}

output "vpc_id" {
  value = aws_vpc.my_vpc.id
}