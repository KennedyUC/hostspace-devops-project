terraform {
  backend "s3" {
    bucket = "bucket-tfstate"
    key    = "env-terraform.tfstate"
    region = "aws-region"
  }
}