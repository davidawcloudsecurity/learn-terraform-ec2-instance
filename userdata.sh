#!/bin/bash
yum update -y
yum install -y httpd
systemctl start httpd
systemctl enable httpd
echo "Q1RGe2gxZGQzbl9pbl90aGVfdXNlcl9kYXRhfQ==" | base64 -d > /var/www/html/flag.txt
echo "<h1>Welcome to the CTF Challenge</h1>" > /var/www/html/index.html
echo "<p>Find the hidden flag!</p>" >> /var/www/html/index.html
