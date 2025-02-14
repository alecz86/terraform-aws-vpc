resource "aws_s3_bucket" "example" {
bucket = "bucket-terraform-${random_string.random.result}"

  tags = {
    Name        = "My bucket"
    Environment = "Dev"
  }
}

resource "random_string" "random" {
  length  = 8
  special = false
  upper   = false
}