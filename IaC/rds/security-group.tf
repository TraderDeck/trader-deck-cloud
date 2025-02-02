resource "aws_security_group" "rds_sg" {
  vpc_id = data.aws_subnet.selected_subnet_source.vpc_id

  ingress {
    from_port   = 5432
    to_port     = 5432
    protocol    = "tcp"
    cidr_blocks = [data.aws_subnet.selected_subnet_source.cidr_block]  
  }

  tags = {
    Name = "rds-security-group"
  }
}

// subnet that is allowed to communicate to rds instance
data "aws_subnet" "selected_subnet_source" {
  filter {
    name   = "tag:Name"
    values = ["subnet-1"]
  }
}