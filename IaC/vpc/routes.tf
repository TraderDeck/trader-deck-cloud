
# Public Route Table
resource "aws_route_table" "public" {
  vpc_id = aws_vpc.my_vpc.id
}

# Public Table Routes
resource "aws_route" "public_internet" {
  route_table_id         = aws_route_table.public.id
  destination_cidr_block = "0.0.0.0/0"
  gateway_id             = aws_internet_gateway.my_igw.id
}

resource "aws_route_table_association" "public_1" {
  subnet_id      = aws_subnet.subnet_1.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_2" {
  subnet_id      = aws_subnet.subnet_2.id
  route_table_id = aws_route_table.public.id
}

resource "aws_route_table_association" "public_3" {
  subnet_id      = aws_subnet.subnet_3.id
  route_table_id = aws_route_table.public.id
}


####################################################

# Private Route Table
resource "aws_route_table" "private" {
  vpc_id = aws_vpc.my_vpc.id
}

# Private Table Routes

resource "aws_route" "private_nat" {
  route_table_id         = aws_route_table.private.id
  destination_cidr_block = "0.0.0.0/0"
  nat_gateway_id         = aws_nat_gateway.my_nat.id
}

resource "aws_route_table_association" "private_1" {
  subnet_id      = aws_subnet.subnet_4.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_2" {
  subnet_id      = aws_subnet.subnet_5.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_3" {
  subnet_id      = aws_subnet.subnet_6.id
  route_table_id = aws_route_table.private.id
}

resource "aws_route_table_association" "private_4" {
  subnet_id      = aws_subnet.subnet_7.id
  route_table_id = aws_route_table.private.id
}
resource "aws_route_table_association" "private_5" {
  subnet_id      = aws_subnet.subnet_8.id
  route_table_id = aws_route_table.private.id
}