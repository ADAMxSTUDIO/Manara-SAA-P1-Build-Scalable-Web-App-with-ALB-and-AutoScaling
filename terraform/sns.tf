resource "aws_sns_topic" "infrastructure_alerts" {
  name = "infrastructure-alerts"
}

resource "aws_sns_topic_subscription" "email" {
  topic_arn = aws_sns_topic.infrastructure_alerts.arn
  protocol  = "email"
  endpoint  = "manara-student@gmail.com"
}