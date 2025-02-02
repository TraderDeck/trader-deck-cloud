
resource "aws_s3_bucket_public_access_block" "public_access" {
  bucket = aws_s3_bucket.ticker_icons.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}

resource "aws_s3_bucket_public_access_block" "td_misc_public_access" {
  bucket = aws_s3_bucket.td-misc.id

  block_public_acls       = true
  block_public_policy     = true
  ignore_public_acls      = true
  restrict_public_buckets = true
}


resource "aws_s3_bucket_policy" "ticker_bucket_policy" {
  bucket = aws_s3_bucket.ticker_icons.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
       {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::676206948384:role/store_ticker_icons_lambda_role"
            },
            "Action": [
          "s3:PutObject",
          "s3:GetObject"
                ],
            "Resource": "arn:aws:s3:::td-ticker-icons/*"
        }
    ]
  })
}

resource "aws_s3_bucket_policy" "td_misc_bucket_policy" {
  bucket = aws_s3_bucket.td-misc.id
  policy = jsonencode({
    Version = "2012-10-17",
    Statement = [
       {
            "Effect": "Allow",
            "Principal": {
                "AWS": "arn:aws:iam::676206948384:role/store_ticker_icons_lambda_role"
            },
            "Action": [
          "s3:PutObject",
          "s3:GetObject"
                ],
            "Resource": "arn:aws:s3:::td-misc/*"
        }
    ]
  })
}


