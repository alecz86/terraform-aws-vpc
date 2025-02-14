output "elasticache_cluster_endpoint" {
    value = aws_elasticache_cluster.redis_db.arn
}