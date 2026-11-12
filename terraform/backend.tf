terraform {
  backend "s3" {
    bucket         = "terraform-state-prod-manara"
    key            = "aws-infra/prod/terraform.tfstate"
    region         = "eu-west-3"
    encrypt        = true
    dynamodb_table = "terraform-locks"
  }
}