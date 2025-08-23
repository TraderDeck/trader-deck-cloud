resource "aws_iam_user" "github_actions_ec2_user" {
  name = "GitHubActionsEC2Deploy"
}

resource "aws_iam_policy" "github_actions_ec2_policy" {
  name        = "GitHubActionsEC2Policy"
  description = "Policy for GitHub Actions to deploy Spring Boot to EC2"

  policy = jsonencode({
    Version = "2012-10-17"
    Statement = [
      {
        Effect = "Allow"
        Action = [
          "ec2:DescribeInstances",
          "ec2:DescribeInstanceStatus",
          "ec2:StartInstances",
          "ec2:StopInstances"
        ]
        Resource = "*"
      },
      {
        Effect = "Allow"
        Action = [
          "ssm:SendCommand",
          "ssm:StartSession",
          "ssm:GetCommandInvocation"
        ]
        Resource = "*"
      }
    ]
  })
}

resource "aws_iam_user_policy_attachment" "github_actions_ec2_attach" {
  user       = aws_iam_user.github_actions_ec2_user.name
  policy_arn = aws_iam_policy.github_actions_ec2_policy.arn
}

resource "aws_iam_access_key" "github_actions_ec2_key" {
  user = aws_iam_user.github_actions_ec2_user.name
}

output "aws_ec2_access_key_id" {
  value     = aws_iam_access_key.github_actions_ec2_key.id
  sensitive = true
}

output "aws_ec2_secret_access_key" {
  value     = aws_iam_access_key.github_actions_ec2_key.secret
  sensitive = true
}

resource "local_file" "github_ec2_secrets" {
  content  = <<EOT
AWS_EC2_ACCESS_KEY_ID=${aws_iam_access_key.github_actions_ec2_key.id}
AWS_EC2_SECRET_ACCESS_KEY=${aws_iam_access_key.github_actions_ec2_key.secret}
EOT
  filename = "github_ec2_secrets.txt"
}
