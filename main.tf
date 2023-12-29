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

resource "aws_instance" "EC2Instance" {
  ami                         = "ami-018ba43095ff50d08"
  instance_type               = "t2.micro"
  key_name                    = "vpc-workshop"
  availability_zone           = "us-east-1a"
  tenancy                     = "default"
  subnet_id                   = "subnet-049d55716a5a097f5" # Public Subnet A
  ebs_optimized               = false
  associate_public_ip_address = true
  vpc_security_group_ids = [
    "sg-026de9cc3638a23fa" # public-facing-security-group
  ]
  source_dest_check = true
  root_block_device {
    volume_size           = 12
    volume_type           = "gp2"
    delete_on_termination = true
  }
  user_data = <<EOF
#!/bin/bash
yum update -y
wget -O /etc/yum.repos.d/jenkins.repo \
   https://pkg.jenkins.io/redhat-stable/jenkins.repo
rpm --import https://pkg.jenkins.io/redhat-stable/jenkins.io-2023.key
# sudo yum upgrade
# Add required dependencies for the jenkins package
cd /home/ec2-user
wget --no-check-certificate -c --header "Cookie: oraclelicense=accept-securebackup-cookie" https://download.oracle.com/java/17/latest/jdk-17_linux-x64_bin.rpm
rpm -Uvh jdk-17_linux-x64_bin.rpm
yum install fontconfig java-17-openjdk -y
yum install jenkins -y
sudo systemctl daemon-reload
sudo systemctl start jenkins
EOF

  tags = {
    Name = "Jenkins-linux-2-terraform"
  }
}
