resource "aws_security_group" "alb_sg" {
  name        = "traderdeck-alb-sg"
  description = "Security group for TraderDeck ALB"
  vpc_id      = data.aws_vpc.existing_vpc.id 

  ingress {
    from_port   = 80
    to_port     = 80
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Open for redirection
  }

  ingress {
    from_port   = 443
    to_port     = 443
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]  # Allow CloudFront traffic
  }

  egress {
    from_port   = 8080
    to_port     = 8080
    protocol    = "tcp"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "traderdeck-alb-sg"
  }
}

data "aws_security_group" "ec2_backend_sg" {
  filter {
    name   = "tag:Name"
    values = ["ec2_backend_sg"] 
  }
}

