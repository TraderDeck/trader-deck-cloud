resource "aws_iam_role" "lambda_role" {
  name = "update_s3_metadata_file_lambda_role"

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
name        = "lambda_vpc_s3_access"
  description = "Policy to allow Lambda to access S3 and manage network interfaces"
  policy      = jsonencode({
    Version = "2012-10-17",
    Statement = [
      {
        Effect   = "Allow",
        Action   = ["s3:ListBucket", "s3:PutObject"],
        Resource = [
          "arn:aws:s3:::td-ticker-icons/",
          "arn:aws:s3:::td-ticker-icons/metadata/info.json"
        ]
      },
      {
        Effect   = "Allow",
        Action   = [
          "ec2:CreateNetworkInterface",
          "ec2:DescribeNetworkInterfaces",
          "ec2:DeleteNetworkInterface",
          "ec2:AssignPrivateIpAddresses",
          "ec2:UnassignPrivateIpAddresses"
        ],
        Resource = "*"
      },
      {
        Effect   = "Allow",
        Action   = ["logs:CreateLogGroup", "logs:CreateLogStream", "logs:PutLogEvents"],
        Resource = "arn:aws:logs:*:*:*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "lambda_s3_attach" {
  policy_arn = aws_iam_policy.lambda_s3_write_policy.arn
  role       = aws_iam_role.lambda_role.name
}
