data "aws_secretsmanager_secret" "db_credentials" {
  name = "traderdeckmain-db-credentials"
}

data "aws_secretsmanager_secret_version" "db_credentials_version" {
  secret_id = data.aws_secretsmanager_secret.db_credentials.id
}

resource "aws_db_instance" "traderdeck_db" {
  identifier              = "traderdeck-db"
  engine                 = "postgres"
  instance_class         = "db.t3.micro" 
  allocated_storage      = 20             
  max_allocated_storage  = 50
  db_name                = "traderdeckmain"
  username               = jsondecode(data.aws_secretsmanager_secret_version.db_credentials_version.secret_string)["username"]
  password               = jsondecode(data.aws_secretsmanager_secret_version.db_credentials_version.secret_string)["password"]
  publicly_accessible    = false
  multi_az               = false
  skip_final_snapshot    = true
  vpc_security_group_ids = [aws_security_group.rds_sg.id]
  db_subnet_group_name   = aws_db_subnet_group.rds_subnet_group.name
}

data "aws_subnet" "selected_subnet_destination_AZa" {
  filter {
    name   = "tag:Name"
    values = ["subnet-5"]
  }
}

data "aws_subnet" "selected_subnet_destination_AZb" {
  filter {
    name   = "tag:Name"
    values = ["subnet-4"]
  }
}

resource "aws_db_subnet_group" "rds_subnet_group" {
  name       = "rds-subnet-group"
  subnet_ids = [data.aws_subnet.selected_subnet_destination_AZa.id, data.aws_subnet.selected_subnet_destination_AZb.id]
}
