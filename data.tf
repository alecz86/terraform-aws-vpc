data "terraform_remote_state" "vpc" {
  backend = "s3"
  config = {
    bucket = aws_s3_bucket.example.bucket
    key    = "path/to/my/key"
    region = "us-east-2"
  }
}

data "terraform_remote_state" "db" {
  backend = "s3"
  config = {
    bucket = aws_s3_bucket.example.bucket
    key    = "path/to/my/db"
    region = "us-east-2"
  }
}
