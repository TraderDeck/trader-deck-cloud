resource "aws_lambda_function" "my_lambda" {
  function_name    = "store_ticker_icons"
  role            = aws_iam_role.lambda_role.arn
  handler         = "lambda_function.lambda_handler"
  runtime         = "python3.10"
  filename        = data.archive_file.lambda_zip.output_path
  source_code_hash = data.archive_file.lambda_zip.output_base64sha256
  timeout = 30
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
