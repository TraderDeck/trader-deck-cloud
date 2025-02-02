resource "aws_vpc" "my_vpc" {
  cidr_block = "10.16.0.0/16"

  tags = {
    Name = "trader-deck-vpc"
  }
}

output "vpc_id" {
  value = aws_vpc.my_vpc.id
}