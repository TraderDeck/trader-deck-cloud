# Public Subnets
resource "aws_subnet" "subnet_1" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.16.0.0/20"
  availability_zone       = "us-east-1a"
  map_public_ip_on_launch = true

  tags = {
    Name        = "subnet-1"
  }
}

resource "aws_subnet" "subnet_2" {
  vpc_id                  = aws_vpc.my_vpc.id
  cidr_block              = "10.16.16.0/20"
  availability_zone       = "us-east-1b"
  map_public_ip_on_launch = true

  tags = {
    Name        = "subnet-2"
  }
}

resource "aws_subnet" "subnet_3" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.16.32.0/20"
  availability_zone = "us-east-1a"

  tags = {
    Name        = "subnet-3"
  }
}


# Private Subnets
resource "aws_subnet" "subnet_4" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.16.48.0/20"
  availability_zone = "us-east-1b"

  tags = {
    Name        = "subnet-4"
  }
}

resource "aws_subnet" "subnet_5" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.16.64.0/20"
  availability_zone = "us-east-1a"

  tags = {
    Name        = "subnet-5"
  }
}

resource "aws_subnet" "subnet_6" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.16.80.0/20"
  availability_zone = "us-east-1b"

  tags = {
    Name        = "subnet-6"
  }
}

resource "aws_subnet" "subnet_7" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.16.96.0/24"
  availability_zone = "us-east-1a"

  tags = {
    Name        = "subnet-7"
  }
}

resource "aws_subnet" "subnet_8" {
  vpc_id            = aws_vpc.my_vpc.id
  cidr_block        = "10.16.112.0/24"
  availability_zone = "us-east-1b"

  tags = {
    Name        = "subnet-8"
  }
}
