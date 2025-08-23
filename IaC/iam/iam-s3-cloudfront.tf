resource "aws_iam_user" "github_actions_user" {
  name = "GitHubActionsDeploy"
}

resource "aws_iam_policy" "github_actions_policy" {
  name        = "GitHubActionsDeployPolicy"
  description = "Policy for GitHub Actions to deploy React to S3 and invalidate CloudFront cache"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect   = "Allow"
        Action   = [
          "s3:PutObject",
          "s3:DeleteObject",
          "s3:ListBucket"
        ]
        Resource = [
          "arn:aws:s3:::traderdeck-frontend-bucket",
          "arn:aws:s3:::traderdeck-frontend-bucket/*"
        ]
      },
      {
        Effect   = "Allow"
        Action   = "cloudfront:CreateInvalidation"
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "github_actions_attach" {
  user       = aws_iam_user.github_actions_user.name
  policy_arn = aws_iam_policy.github_actions_policy.arn
}

resource "aws_iam_access_key" "github_actions_key" {
  user = aws_iam_user.github_actions_user.name
}

output "aws_access_key_id" {
  value     = aws_iam_access_key.github_actions_key.id
  sensitive = true
}

output "aws_secret_access_key" {
  value     = aws_iam_access_key.github_actions_key.secret
  sensitive = true
}

resource "local_file" "github_secrets" {
  content  = <<EOT
AWS_ACCESS_KEY_ID=${aws_iam_access_key.github_actions_key.id}
AWS_SECRET_ACCESS_KEY=${aws_iam_access_key.github_actions_key.secret}
EOT
  filename = "github_secrets.txt"
}
