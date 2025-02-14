data "aws_route53_zone" "my_zone" {
  name = "amazon1app.com"
}

# Writer Endpoint
resource "aws_route53_record" "writer" {
  zone_id = var.zone_id
  name    = var.writer_name
  type    = "CNAME"
  ttl     = 300
  records = [aws_rds_cluster.aurora_cluster.endpoint]
}

# Reader Endpoints
resource "aws_route53_record" "reader1" {
  zone_id = var.zone_id
  name    = var.reader1_name
  type    = "CNAME"
  ttl     = 300
  records = [aws_rds_cluster_instance.reader1.endpoint]
}

resource "aws_route53_record" "reader2" {
  zone_id = var.zone_id
  name    = var.reader2_name
  type    = "CNAME"
  ttl     = 300
  records = [aws_rds_cluster_instance.reader2.endpoint]
}

resource "aws_route53_record" "reader3" {
  zone_id = var.zone_id
  name    = var.reader3_name
  type    = "CNAME"
  ttl     = 300
  records = [aws_rds_cluster_instance.reader3.endpoint]
}
