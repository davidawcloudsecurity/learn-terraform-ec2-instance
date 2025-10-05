#!/bin/bash

# Update system and install packages
apt update -y
apt install -y apache2 php libapache2-mod-php awscli git curl

# Create directory structure
mkdir -p /var/www/html
chown -R www-data:www-data /var/www/html

# Enable Apache modules
a2enmod rewrite

# Create default virtual host
cat > /etc/apache2/sites-available/000-default.conf << 'EOF'
<VirtualHost *:80>
    DocumentRoot /var/www/html
    
    <Directory /var/www/html>
        Options Indexes FollowSymLinks
        AllowOverride All
        Require all granted
    </Directory>
    
    ErrorLog ${APACHE_LOG_DIR}/error.log
    CustomLog ${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF

# Enable site
a2ensite 000-default.conf

# Clone and deploy blog website
cd /tmp
git clone https://github.com/davidawcloudsecurity/learn-terraform-ec2-instance.git
cp -r /tmp/learn-terraform-ec2-instance/personal-blog-website/* /var/www/html/

# Get bucket name from instance metadata/tags
BUCKET_NAME=$(aws ec2 describe-tags --region $(curl -s http://169.254.169.254/latest/meta-data/placement/region) --filters "Name=resource-id,Values=$(curl -s http://169.254.169.254/latest/meta-data/instance-id)" "Name=key,Values=BucketName" --query 'Tags[0].Value' --output text 2>/dev/null || echo "thetoppers-htb-bucket")

# Upload images to S3
if [ -d "/var/www/html/assets/images" ]; then
    aws s3 sync /var/www/html/assets/images/ s3://$BUCKET_NAME/images/
fi

# Create .htaccess to redirect images to S3
cat > /var/www/html/.htaccess << EOF
RewriteEngine On
RewriteRule ^assets/images/(.*)$ https://$BUCKET_NAME.s3.amazonaws.com/images/\$1 [R=301,L]
EOF

# Create test files
echo "<?php phpinfo(); ?>" > /var/www/html/info.php
echo "Test file from real S3" > /tmp/test.txt

# Upload test file to S3
aws s3 cp /tmp/test.txt s3://$BUCKET_NAME/

# Set proper permissions
chown -R www-data:www-data /var/www/html
chmod -R 755 /var/www/html

# Restart Apache
systemctl restart apache2

# Create verification script
cat > /home/ubuntu/verify-setup.sh << EOF
#!/bin/bash
echo "=== Real S3 Verification ==="
echo "1. S3 Bucket: $BUCKET_NAME"
aws s3 ls s3://$BUCKET_NAME/

echo -e "\n2. Testing web access:"
curl -s http://localhost/ | head -1

echo -e "\n3. Apache status:"
systemctl is-active apache2
EOF

chmod +x /home/ubuntu/verify-setup.sh
/home/ubuntu/verify-setup.sh > /home/ubuntu/setup-verification.log 2>&1