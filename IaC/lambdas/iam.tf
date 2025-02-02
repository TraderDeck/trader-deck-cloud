resource "aws_iam_role" "lambda_role" {
  name = "store_ticker_icons_lambda_role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "lambda.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "lambda_s3_write_policy" {
  name        = "store_ticker_icons_lambda_s3_write_policy"
  description = "Allows the Lambda function to write to the S3 bucket"

  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [{
      Effect = "Allow",
      Action = [
        "s3:PutObject", 
        "s3:GetObject", 
      ],
      Resource = [
        "arn:aws:s3:::td-ticker-icons/*", 
        "arn:aws:s3:::td-misc/*"
      ]
    }]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_attach" {
  policy_arn = aws_iam_policy.lambda_s3_write_policy.arn
  role       = aws_iam_role.lambda_role.name
}
