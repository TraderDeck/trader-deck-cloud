# Public Subnets
resource "aws_subnet" "subnet_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.16.0.0/20"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.16.16.0/20"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true
}

resource "aws_subnet" "subnet_3" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.16.32.0/20"
  availability_zone = "us-east-1a"
}


# Private Subnets
resource "aws_subnet" "subnet_4" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.16.48.0/20"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "subnet_5" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.16.64.0/20"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "subnet_6" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.16.80.0/20"
  availability_zone = "us-east-1b"
}

resource "aws_subnet" "subnet_7" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.16.96.0/24"
  availability_zone = "us-east-1a"
}

resource "aws_subnet" "subnet_8" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.16.112.0/24"
  availability_zone = "us-east-1b"
}
