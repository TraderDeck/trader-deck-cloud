resource "aws_lambda_function" "my_lambda" {
  function_name    = "update_s3_metadata_file"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  runtime         = "python3.10"
  filename        = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout = 30

   vpc_config {
    subnet_ids         = [data.aws_subnet.lambda_subnet.id]
    security_group_ids = [aws_security_group.lambda_sg.id]
  }

  environment {
    variables = {
      BUCKET_NAME       = "td-ticker-icons"
      METADATA_FILE_PATH = "metadata/info.json"
    }
  }
}

data "aws_vpc" "existing_vpc" {
  filter {
    name   = "tag:Name"
    values = ["trader-deck-vpc"]
  }
}

data "aws_subnet" "lambda_subnet" {
  filter {
    name   = "tag:Name"
    values = ["subnet-5"]
  }

  filter {
    name   = "vpc-id"
    values = [data.aws_vpc.existing_vpc.id] 
  }
}

resource "aws_security_group" "lambda_sg" {
  name        = "lambda_sg"
  description = "Security Group for Lambda in VPC"
  vpc_id      = data.aws_vpc.existing_vpc.id

  # Outbound rule to allow all traffic (needed for S3 VPC endpoint)
  egress {
    from_port   = 0
    to_port     = 0
    protocol    = "-1"
    cidr_blocks = ["0.0.0.0/0"]
  }

  tags = {
    Name = "LambdaSecurityGroup"
  }
}

resource "null_resource" "package_lambda" {
  provisioner "local-exec" {
    command = <<EOT
      rm -rf lambda_src
      mkdir -p lambda_src
      cp lambda_function.py lambda_src/
      pip install -r requirements.txt -t lambda_src/
    EOT
  }

  triggers = {
    always_run = "${timestamp()}"
  }
}


data "archive_file" "lambda_zip" {
  depends_on  = [null_resource.package_lambda] 
  type        = "zip"
  source_dir  = "${path.module}/lambda_src"
  output_path = "${path.module}/lambda_function.zip"

}
