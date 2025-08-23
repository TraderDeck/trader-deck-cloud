
#commented for now to reduce cost

# Internet Gateway for Public Subnets
resource "aws_internet_gateway" "my_igw" {
  vpc_id = aws_vpc.my_vpc.id
}

resource "aws_eip" "nat" {
  domain = "vpc"
}

resource "aws_nat_gateway" "my_nat" {
  allocation_id = aws_eip.nat.id
  subnet_id     = aws_subnet.subnet_1.id
}