resource "aws_instance" "springboot" {
  ami                    = "ami-01f5a0b78d6089704"
  instance_type          = "t3.micro"
  subnet_id              = data.aws_subnet.ec2_private_subnet.id
  iam_instance_profile   = aws_iam_instance_profile.ec2_instance_profile.name
  vpc_security_group_ids = [aws_security_group.backend_sg.id]
  key_name               = "traderdeck-key"

  user_data = <<-EOF
              #!/bin/bash
              set -e  # Exit on error

              # Update packages
              sudo yum update -y
              sudo amazon-linux-extras enable corretto8
              sudo yum install -y java-17-amazon-corretto jq aws-cli

              # Add PostgreSQL 14 Repository
              sudo tee /etc/yum.repos.d/pgdg.repo <<EOL
              [pgdg14]
              name=PostgreSQL 14 for Amazon Linux 2
              baseurl=https://download.postgresql.org/pub/repos/yum/14/redhat/rhel-7-x86_64/
              enabled=1
              gpgcheck=0
              EOL

              # Install PostgreSQL 14 Client
              sudo yum install -y postgresql14 postgresql14-server

              # Retrieve database credentials from AWS Secrets Manager
              SECRET_JSON=$(aws secretsmanager get-secret-value --secret-id traderdeckmain-db-credentials --query SecretString --output text)

              # Extract database details
              DB_HOST=$(echo "$SECRET_JSON" | jq -r '.host')
              DB_USER=$(echo "$SECRET_JSON" | jq -r '.username')
              DB_PASS=$(echo "$SECRET_JSON" | jq -r '.password')

              # Export credentials to environment variables (Wrap password in double quotes)
              echo "DB_URL='jdbc:postgresql://$DB_HOST:5432/traderdeckmain'" | sudo tee -a /home/ec2-user/.env
              echo "DB_USERNAME=$DB_USER" | sudo tee -a /home/ec2-user/.env
              echo "DB_PASSWORD=\"$DB_PASS\"" | sudo tee -a /home/ec2-user/.env

              # Load environment variables
              source /home/ec2-user/.env

              EOF


  tags = {
    Name = "TraderDeck-Backend"
  }
}

resource "aws_iam_instance_profile" "ec2_instance_profile" {
  name = "TraderDeckEC2InstanceProfile"
  role = aws_iam_role.ec2_role.name
}


data "aws_vpc" "existing_vpc" {
  filter {
    name   = "tag:Name"
    values = ["trader-deck-vpc"]
  }
}

data "aws_subnet" "ec2_private_subnet" {
  filter {
    name   = "tag:Name"
    values = ["subnet-5"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing_vpc.id] 
  }
}

output "backend_private_ip" {
  value = aws_instance.springboot.private_ip
}

output "backend_public_ip" {
  value = aws_instance.springboot.public_ip
}

