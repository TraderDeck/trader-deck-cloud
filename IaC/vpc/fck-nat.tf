resource "aws_instance" "fck_nat" {
  ami           = "ami-01f5a0b78d6089704"
  instance_type = "t3.nano" 
  subnet_id     = aws_subnet.subnet_1.id
  key_name      = "traderdeck-key"
  associate_public_ip_address = true
  vpc_security_group_ids       = [aws_security_group.fck_nat_sg.id]


  user_data = <<-EOF
              #!/bin/bash
              curl -fsSL https://fck-nat.dev/stable/install.sh | sudo bash
              EOF

  tags = {
    Name = "fck-nat"
  }
}


resource "aws_security_group" "fck_nat_sg" {
  name        = "fck-nat-sg"
  description = "Allow traffic to and from fck_nat instance"
  vpc_id      = aws_vpc.my_vpc.id

  ingress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "fck-nat-sg"
  }
}