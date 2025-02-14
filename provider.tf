provider aws {
    region = "${var.region}"
}

data "aws_availability_zones" "av-azs" {
  state = "available"
}

