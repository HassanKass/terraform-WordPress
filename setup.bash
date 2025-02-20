#!/bin/bash
set -e

# Install Apache & PHP
sudo yum install -y httpd
sudo systemctl enable httpd
sudo systemctl start httpd
sudo amazon-linux-extras enable php8.2 mariadb10.5
sudo yum install -y php php-common php-cli php-fpm php-mysqlnd php-pdo php-json php-xml php-mbstring mod_php httpd-tools
sudo systemctl restart php-fpm

# Download WordPress
wget -O /tmp/latest.tar.gz https://wordpress.org/latest.tar.gz
tar -xzf /tmp/latest.tar.gz -C /var/www/html/
sudo chown -R apache:apache /var/www/html/wordpress
sudo chmod -R 755 /var/www/html/wordpress

# Update Apache
sudo sed -i 's|DocumentRoot "/var/www/html"|DocumentRoot "/var/www/html/wordpress"|' /etc/httpd/conf/httpd.conf
sudo sed -i 's/DirectoryIndex index.html/DirectoryIndex index.php index.html/' /etc/httpd/conf/httpd.conf
sudo systemctl restart httpd

# Wait for RDS
echo "Waiting for RDS to be available..."
until aws rds describe-db-instances --db-instance-identifier wordpress-db --query "DBInstances[0].DBInstanceStatus" --output text --region us-east-2 | grep -q "available"; do
    sleep 15
done

# Get RDS Endpoint
while [[ -z "$RDS_ENDPOINT" || "$RDS_ENDPOINT" == "None" ]]; do
    RDS_ENDPOINT=$(aws rds describe-db-instances --query "DBInstances[?DBInstanceIdentifier=='wordpress-db'].Endpoint.Address" --output text --region us-east-2)
    sleep 3
done

# Configure wp-config
cd /var/www/html/wordpress
cp wp-config-sample.php wp-config.php
sed -i "s/database_name_here/wordpress/" wp-config.php
sed -i "s/username_here/admin/" wp-config.php
sed -i "s/password_here/adminadmin/" wp-config.php
sed -i "s/localhost/$RDS_ENDPOINT/" wp-config.php
curl -s https://api.wordpress.org/secret-key/1.1/salt/ >> wp-config.php
sudo chown apache:apache wp-config.php

# Install MySQL Client and netcat for testing connectivity
sudo yum install -y mysql netcat

# Ensure Database is Created
echo "Checking if 'wordpress' database exists on RDS..."

mysql -h "$RDS_ENDPOINT" -u admin -padminadmin -e "CREATE DATABASE IF NOT EXISTS wordpress;"

# Restart services
sudo systemctl restart httpd php-fpm

echo "WordPress setup is complete!"
