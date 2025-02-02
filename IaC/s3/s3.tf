resource "aws_s3_bucket" "ticker_icons" {
  bucket = "td-ticker-icons"
  
  tags = {
    Name        = "td-ticker-icons"
  }
}

resource "aws_s3_bucket" "td-misc" {
  bucket = "td-misc"
  
  tags = {
    Name        = "td-misc"
  }
}
