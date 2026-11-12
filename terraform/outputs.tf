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

output "ssm_instance_profile_name" {
  description = "IAM instance profile used by the application instances for Session Manager."
  value       = aws_iam_instance_profile.ssm.name
}

output "ssm_endpoint_ids" {
  description = "Private interface endpoint IDs used by Session Manager."
  value = {
    ssm         = aws_vpc_endpoint.ssm.id
    ssmmessages = aws_vpc_endpoint.ssmmessages.id
    ec2messages = aws_vpc_endpoint.ec2messages.id
  }
}