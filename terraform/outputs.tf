output "alb_dns_name" {
  value = aws_lb.alb.dns_name
}

output "database_endpoint" {
  value = aws_db_instance.mysql.endpoint
}

output "cloudfront_domain_name" {
  value = aws_cloudfront_distribution.main.domain_name
}

output "application_url" {
  value = "https://${var.domain_name}"
}