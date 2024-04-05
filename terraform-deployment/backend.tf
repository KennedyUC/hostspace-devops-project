terraform {
  backend "s3" {
    bucket = "school-app-tfstate"
    key    = "dev/terraform.tfstate"
    region = "us-east-1"
  }
}