resource "aws_security_group" "rds_sg" {
  name        = "traderdeck-rds-sg"
  description = "Security group for TraderDeck PostgreSQL RDS"
  vpc_id      = data.aws_vpc.existing_vpc.id 

  ingress {
    description     = "Allow RDS access from backend EC2"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [data.aws_security_group.ec2_backend_sg.id]
  }

  ingress {
    description     = "Allow RDS access from Bastion host"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [data.aws_security_group.bastion_sg.id]
  }

  ingress {
    description     = "Allow RDS access from Lambda"
    from_port       = 5432
    to_port         = 5432
    protocol        = "tcp"
    security_groups = [data.aws_security_group.lambda_sg.id]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "traderdeck-rds-sg"
  }
}

data "aws_vpc" "existing_vpc" {
  filter {
    name   = "tag:Name"
    values = ["trader-deck-vpc"]
  }
}

data "aws_security_group" "ec2_backend_sg" {
  filter {
    name   = "tag:Name"
    values = ["ec2_backend_sg"] 
  }
}

data "aws_security_group" "bastion_sg" {
  filter {
    name   = "tag:Name"
    values = ["bastion_sg"]
  }
}

data "aws_security_group" "lambda_sg" {
  filter {
    name   = "group-name"
    values = ["lambda-rds-access-sg"] 
  }

  vpc_id = data.aws_vpc.existing_vpc.id
}