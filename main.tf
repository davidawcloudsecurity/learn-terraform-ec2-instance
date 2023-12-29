terraform {
  required_providers {
    aws = {
      source  = "hashicorp/aws"
      version = "~> 3.0"
    }
  }
}
provider "aws" {
  region = "us-east-1"
}

resource "aws_instance" "prod-instance" {
  ami                         = "ami-018ba43095ff50d08"
  instance_type               = "t2.micro"
  key_name                    = "vpc-workshop"
  availability_zone           = "us-east-1a"
  tenancy                     = "default"
  subnet_id                   = "subnet-049d55716a5a097f5" # Public Subnet A
  ebs_optimized               = false
#  associate_public_ip_address = true
  vpc_security_group_ids = [
    "sg-026de9cc3638a23fa" # public-facing-security-group
  ]
  source_dest_check = true
  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
  }

  user_data = <<EOF
#!/bin/bash
yum update -y
EOF

  tags = {
    Name = "prod-instance-linux-2-terraform"
    Env= "prod"
  }
}

resource "aws_instance" "dev-instance" {
  ami                         = "ami-018ba43095ff50d08"
  instance_type               = "t2.micro"
  key_name                    = "vpc-workshop"
  availability_zone           = "us-east-1a"
  tenancy                     = "default"
  subnet_id                   = "subnet-049d55716a5a097f5" # Public Subnet A
  ebs_optimized               = false
#  associate_public_ip_address = true
  vpc_security_group_ids = [
    "sg-026de9cc3638a23fa" # public-facing-security-group
  ]
  source_dest_check = true
  root_block_device {
    volume_size           = 8
    volume_type           = "gp2"
    delete_on_termination = true
  }

  user_data = <<EOF
#!/bin/bash
yum update -y
EOF

  tags = {
    Name = "dev-instance-linux-2-terraform"
    Env= "dev"
  }
}
