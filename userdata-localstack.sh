#!/bin/bash

# Update system and install packages
apt update -y
apt install -y docker.io docker-compose apache2 php libapache2-mod-php awscli curl

# Start and enable Docker
systemctl start docker
systemctl enable docker
usermod -aG docker ubuntu

# Create directory structure
mkdir -p /var/www/html
mkdir -p /tmp/localstack/data
chown -R www-data:www-data /var/www/html

# Create Docker Compose file for LocalStack
cat > /home/ubuntu/docker-compose.yml << 'EOF'
version: '3.8'
services:
  localstack:
    image: localstack/localstack:0.14.2
    container_name: localstack
    ports:
      - "127.0.0.1:4566:4566"
    environment:
      - DEBUG=1
      - SERVICES=s3
      - DATA_DIR=/tmp/localstack/data
    volumes:
      - /var/www/html:/tmp/localstack/data
    restart: unless-stopped
EOF

# Enable Apache modules
a2enmod rewrite
a2enmod proxy
a2enmod proxy_http
a2enmod headers

# Create main Apache virtual host
cat > /etc/apache2/sites-available/thetoppers.htb.conf << 'EOF'
<VirtualHost *:80>
    ServerName thetoppers.htb
    DocumentRoot /var/www/html
    
    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/thetoppers_error.log
    CustomLog ${APACHE_LOG_DIR}/thetoppers_access.log combined
</VirtualHost>
EOF

# Create S3 proxy virtual host
cat > /etc/apache2/sites-available/s3.thetoppers.htb.conf << 'EOF'
<VirtualHost *:80>
    ServerName s3.thetoppers.htb
    
    ProxyPreserveHost Off
    ProxyRequests Off
    
    ProxyPass / http://127.0.0.1:4566/
    ProxyPassReverse / http://127.0.0.1:4566/
    
    ErrorLog ${APACHE_LOG_DIR}/s3_thetoppers_error.log
    CustomLog ${APACHE_LOG_DIR}/s3_thetoppers_access.log combined
</VirtualHost>
EOF

# Create default virtual host for localhost
cat > /etc/apache2/sites-available/000-default.conf << 'EOF'
<VirtualHost *:80>
    DocumentRoot /var/www/html
    
    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
EOF

# Enable sites
a2ensite 000-default.conf
a2ensite thetoppers.htb.conf
a2ensite s3.thetoppers.htb.conf

# Configure hosts file
cat >> /etc/hosts << 'EOF'
127.0.0.1 thetoppers.htb
127.0.0.1 s3.thetoppers.htb
EOF

# Start LocalStack
cd /home/ubuntu
docker-compose up -d

# Wait for LocalStack to be ready
sleep 30

# Wait for LocalStack S3 service to be fully ready
for i in {1..10}; do
    if curl -s http://127.0.0.1:4566/_localstack/health | grep -q '"s3": "available"'; then
        break
    fi
    echo "Waiting for LocalStack S3 service... attempt $i"
    sleep 10
done

# Create S3 bucket with retry
for i in {1..3}; do
    if aws --endpoint-url=http://127.0.0.1:4566 s3 mb s3://thetoppers.htb; then
        echo "S3 bucket created successfully"
        break
    fi
    echo "Failed to create S3 bucket, retrying... attempt $i"
    sleep 5
done

# Clone and deploy blog website
apt install -y git
cd /tmp
git clone https://github.com/davidawcloudsecurity/learn-terraform-ec2-instance.git
cp -r /tmp/learn-terraform-ec2-instance/personal-blog-website/* /var/www/html/

# Create test files
echo "<?php phpinfo(); ?>" > /var/www/html/info.php
echo "Test file from S3" > /tmp/test.txt

# Upload test file to S3
aws --endpoint-url=http://127.0.0.1:4566 s3 cp /tmp/test.txt s3://thetoppers.htb/

# Set proper permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Restart Apache
systemctl restart apache2

# Create verification script
cat > /home/ubuntu/verify-setup.sh << 'EOF'
#!/bin/bash
echo "=== Verification Script ==="
echo "1. Testing LocalStack S3:"
aws --endpoint-url=http://127.0.0.1:4566 s3 ls s3://thetoppers.htb/

echo -e "\n2. Testing web access:"
curl -s http://thetoppers.htb/ | head -1

echo -e "\n3. Testing S3 API access:"
curl -s http://s3.thetoppers.htb/ | head -1

echo -e "\n4. Docker status:"
docker ps | grep localstack

echo -e "\n5. Apache status:"
systemctl is-active apache2
EOF

chmod +x /home/ubuntu/verify-setup.sh

# Run verification
/home/ubuntu/verify-setup.sh > /home/ubuntu/setup-verification.log 2>&1