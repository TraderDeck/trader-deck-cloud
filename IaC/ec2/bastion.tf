resource "aws_instance" "bastion" {
  ami           = "ami-01f5a0b78d6089704"
  instance_type = "t3.micro"
  subnet_id     = data.aws_subnet.ec2_public_subnet_1.id
  key_name      = "traderdeck-key"
  associate_public_ip_address = true
  vpc_security_group_ids = [aws_security_group.bastion_sg.id]

  tags = {
    Name = "Bastion-Host"
  }
}

data "aws_subnet" "ec2_public_subnet_1" {
  filter {
    name   = "tag:Name"
    values = ["subnet-1"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing_vpc.id] 
  }
}

output "bastion_private_ip" {
  value = aws_instance.bastion.private_ip
}

output "bastion_public_ip" {
  value = aws_instance.bastion.public_ip
}

