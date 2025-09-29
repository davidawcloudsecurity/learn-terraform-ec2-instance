terraform {
  backend "s3" {
    bucket         = "learn-terraform-ec2-instance-terraform-state"
    key            = "project1/terraform.tfstate"
    region         = "us-east-1"
    dynamodb_table = "terraform-locks"
    encrypt        = true
  }
}
