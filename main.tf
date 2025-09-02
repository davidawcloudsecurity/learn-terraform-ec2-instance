
terraform {
  required_version = ">= 1.1.5"
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "4.23.0"
    }
  }
}

provider "aws" {
  region = var.aws_region
}

resource "aws_instance" "ec2" {
    count = local.instance_number
  instance_type = var.instance_type
  ami           = data.aws_ami.ami.image_id
}

locals {
  instance_number = 2
}

variable "aws_region" {
  type    = string
  default = "us-east-1"
}

variable "instance_type" {
  type    = string
  default = "t2.micro"
}

data "aws_ami" "ami" {

  owners      = ["amazon"]
  most_recent = true

  filter {
    name   = "virtualization-type"
    values = ["hvm"]
  }
}

output "instanceid" {
  value = aws_instance.ec2.*.id
}
