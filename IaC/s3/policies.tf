
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

      # Allow CloudFront to Read Ticker Images from S3
     {
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudfront.amazonaws.com"
            },
            "Action": "s3:GetObject",
            "Resource": "arn:aws:s3:::td-ticker-icons/*",
            "Condition": {
                "StringEquals": {
                    "AWS:SourceArn": "arn:aws:cloudfront::676206948384:distribution/E2B888RLOCPHQM"
                }
            }
        },
        {
            "Effect": "Allow",
            "Principal": {
                "Service": "cloudfront.amazonaws.com"
            },
            "Action": "s3:ListBucket",
            "Resource": "arn:aws:s3:::td-ticker-icons",
            "Condition": {
                "StringEquals": {
                    "AWS:SourceArn": "arn:aws:cloudfront::676206948384:distribution/E2B888RLOCPHQM"
                }
            }
      },
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::676206948384:user/s3-user"
        },
        "Action": "s3:*",
        "Resource": [
          "arn:aws:s3:::td-ticker-icons",
          "arn:aws:s3:::td-ticker-icons/*"
        ]
      },

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
      },

      {
        "Effect": "Allow",
        "Principal": {
          "AWS": "arn:aws:iam::676206948384:role/update_s3_metadata_file_lambda_role"
        },
        "Action": [
          "s3:PutObject",
          "s3:GetObject"
        ],
        "Resource": "arn:aws:s3:::td-ticker-icons/*"
      },

      # Fix: Apply "s3:ListBucket" at the bucket level only
      {
        "Effect": "Allow",
        "Principal": {
          "AWS": [
            "arn:aws:iam::676206948384:role/store_ticker_icons_lambda_role",
            "arn:aws:iam::676206948384:role/update_s3_metadata_file_lambda_role"
          ]
        },
        "Action": "s3:ListBucket",
        "Resource": "arn:aws:s3:::td-ticker-icons"
      }
    ]
  })
}


resource "aws_s3_bucket_cors_configuration" "td_ticker_icons_cors" {
  bucket = aws_s3_bucket.ticker_icons.id

  cors_rule {
    allowed_methods = ["GET"]
    allowed_origins = ["http://localhost:5173", "https://mytraderdeck.com"]
    allowed_headers = ["*"]
    expose_headers  = ["ETag"]
    max_age_seconds = 3000
  }
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
        }, 
        {
            Effect    = "Allow"
            Principal = {
              AWS = "arn:aws:iam::676206948384:role/TraderDeckEC2Role"
            }
            Action   = "s3:GetObject"
            Resource = "arn:aws:s3:::td-misc/list_tickers_nasdaq.csv"
        }

    ]
  })
}



data "aws_cloudfront_distribution" "frontend_cdn" {
  id = "E2B888RLOCPHQM"
}


