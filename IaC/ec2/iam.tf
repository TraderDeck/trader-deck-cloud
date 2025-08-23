resource "aws_iam_role" "ec2_role" {
  name = "TraderDeckEC2Role"

  assume_role_policy = jsonencode({
    Version = "2012-10-17"
    Statement = [{
      Effect = "Allow"
      Principal = {
        Service = "ec2.amazonaws.com"
      }
      Action = "sts:AssumeRole"
    }]
  })
}

resource "aws_iam_policy" "ec2_s3_secrets_policy" {
  name        = "EC2S3SecretsPolicy"
  description = "Allows EC2 to access AWS Secrets Manager and S3"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "s3:GetObject"
        ]
        Resource = "arn:aws:s3:::td-misc/list_tickers_nasdaq.csv"
      },
      {
        Effect = "Allow"
        Action = [
          "secretsmanager:GetSecretValue"
        ]
        Resource = "arn:aws:secretsmanager:us-east-1:676206948384:secret:traderdeckmain-db-credentials-*"
      }
    ]
  })
}

resource "aws_iam_role_policy_attachment" "attach_s3_secrets" {
  role       = aws_iam_role.ec2_role.name
  policy_arn = aws_iam_policy.ec2_s3_secrets_policy.arn
}

