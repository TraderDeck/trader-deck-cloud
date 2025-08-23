resource "aws_cloudfront_origin_access_identity" "s3_oai" {
  comment = "OAI for TraderDeck S3 bucket"
}


resource "aws_cloudfront_origin_access_control" "s3_oac" {
  name                              = "td-ticker-icons-oac"
  description                       = "OAC for td-ticker-icons S3 bucket"
  origin_access_control_origin_type = "s3"
  signing_behavior                  = "always"
  signing_protocol                  = "sigv4"
}

