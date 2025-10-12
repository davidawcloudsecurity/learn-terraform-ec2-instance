#!/bin/bash

# Create ssm-user2 with password for both yum and apt systems
useradd -m ssm-user2
usermod -aG wheel ssm-user2
usermod -aG sudo ssm-user2
echo 'ssm-user2:P@ssw0rd123!' | chpasswd

# Install packages based on available package manager
if command -v yum &> /dev/null; then
    yum update -y
    yum install -y httpd git
    systemctl start httpd
    systemctl enable httpd
elif command -v apt &> /dev/null; then
    apt update -y
    apt install -y apache2 git
    systemctl start apache2
    systemctl enable apache2
fi

# Set web root based on system
if [ -d "/var/www/html" ]; then
    WEB_ROOT="/var/www/html"
else
    WEB_ROOT="/var/www/html"
    mkdir -p $WEB_ROOT
fi

# Clone repository and copy website content
cd /tmp
git clone https://github.com/davidawcloudsecurity/learn-terraform-ec2-instance.git
cp -r /tmp/learn-terraform-ec2-instance/personal-blog-website/* $WEB_ROOT/

echo "Q1RGe2gxZGQzbl9pbl90aGVfdXNlcl9kYXRhfQ==" | base64 -d > $WEB_ROOT/flag.txt
