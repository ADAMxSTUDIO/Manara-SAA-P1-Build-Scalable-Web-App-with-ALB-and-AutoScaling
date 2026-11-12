variable "aws_region" {
  type    = string
  default = "eu-west-1"
}

variable "instance_type" {
  default = "t3.micro"
}

variable "db_username" {
  type = string
}

variable "db_password" {
  type      = string
  sensitive = true
}

variable "domain_name" {
  type        = string
  description = "Public DNS name for the application, such as app.example.com."
}

variable "route53_zone_id" {
  type        = string
  description = "Existing public Route 53 hosted zone ID containing domain_name."
}