resource "aws_security_group" "backend_sg" {
  name        = "ec2_backend_sg"
  description = "Allow API access from ALB and SSH from Bastion"
  vpc_id      = data.aws_vpc.existing_vpc.id

# ✅ Allow HTTP/HTTPS Traffic from ALB
  ingress {
    from_port       = 8080
    to_port         = 8080
    protocol        = "tcp"
    security_groups = [data.aws_security_group.alb_sg.id]  # Only ALB can access Backend API
  }

  # ✅ Allow SSH Only from Bastion Host
  ingress {
    from_port       = 22
    to_port         = 22
    protocol        = "tcp"
    security_groups = [aws_security_group.bastion_sg.id]  # Only Bastion can SSH to Backend
  }

  # ✅ Allow All Internal Traffic from fck-nat (For Outbound Internet)
  # ingress {
  #   from_port       = 0
  #   to_port         = 0
  #   protocol        = "-1"
  #   security_groups = [data.aws_security_group.fck-nat-sg.id]  # Only fck-nat can communicate with Backend EC2
  # }
  # ingress {
  #   from_port       = 0
  #   to_port         = 0
  #   protocol        = "-1"
  #   cidr_blocks = ["0.0.0.0/0"]  # Only fck-nat can communicate with Backend EC2
  # }
  # ❌ REMOVE THIS: It is insecure!
  # ingress {
  #   from_port   = 0
  #   to_port     = 0
  #   protocol    = "-1"
  #   cidr_blocks = ["0.0.0.0/0"]
  # }
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]  # Allow outgoing HTTP traffic
  }

  # ✅ Outbound: Allow HTTP/HTTPS for Software Updates & API Calls
  # egress {
  #   from_port   = 80
  #   to_port     = 80
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]  # Allow outgoing HTTP traffic
  # }

  # egress {
  #   from_port   = 443
  #   to_port     = 443
  #   protocol    = "tcp"
  #   cidr_blocks = ["0.0.0.0/0"]  # Allow outgoing HTTPS traffic
  # }


  # # ✅ Outbound: Allow Internet Access via fck-nat
  # egress {
  #   from_port       = 0
  #   to_port         = 0
  #   protocol        = "-1"
  #   security_groups = [data.aws_security_group.fck-nat-sg.id]  # Ensure traffic flows through fck-nat
  # }

  tags = {
    Name = "ec2_backend_sg"
  }
}

data "aws_security_group" "alb_sg" {
  filter {
    name   = "tag:Name"
    values = ["traderdeck-alb-sg"] 
  }
}

data "aws_security_group" "fck-nat-sg" {
  filter {
    name   = "tag:Name"
    values = ["fck-nat-sg"] 
  }
}
