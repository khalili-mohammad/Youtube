#!/bin/bash

# Define Variables
DB_ROOT_PASS="rootpassword"
WP_DB_NAME="wordpress_db"
WP_DB_USER="wordpress_user"
WP_DB_PASS="wordpress_pass"
DOMAIN="wordpress.example.com"  # Set your Domain or Subdomain
EMAIL="mail@example.com"

# Update System
echo "[+] Updating system..."
sudo apt update && sudo apt upgrade -y

# Install Necessary Packages
echo "[+] Installing Apache, MySQL, PHP, Certbot, and phpMyAdmin..."
sudo apt install -y apache2 mysql-server php libapache2-mod-php php-mysql php-cli php-curl php-zip php-xml unzip wget curl certbot python3-certbot-apache phpmyadmin

# Configure MySQL
echo "[+] Configuring MySQL..."
sudo systemctl start mysql
sudo systemctl enable mysql

sudo mysql -u root -p"$DB_ROOT_PASS" <<EOF
CREATE DATABASE IF NOT EXISTS $WP_DB_NAME;
CREATE USER IF NOT EXISTS '$WP_DB_USER'@'localhost' IDENTIFIED BY '$WP_DB_PASS';
GRANT ALL PRIVILEGES ON $WP_DB_NAME.* TO '$WP_DB_USER'@'localhost';
ALTER USER 'phpmyadmin'@'localhost' IDENTIFIED BY '$DB_ROOT_PASS';
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$DB_ROOT_PASS';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF

# Configure phpMyAdmin
echo "[+] Configuring phpMyAdmin..."
sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin

# Allow root login in phpMyAdmin
echo "[+] Allowing root login in phpMyAdmin..."
sudo sed -i "s/^\$cfg\['Servers'\]\[\$i\]\['auth_type'\] = 'cookie';/\$cfg\['Servers'\]\[\$i\]\['auth_type'\] = 'config';/" /etc/phpmyadmin/config.inc.php
sudo sed -i "s/^\$cfg\['Servers'\]\[\$i\]\['user'\] = 'phpmyadmin';/\$cfg\['Servers'\]\[\$i\]\['user'\] = 'root';/" /etc/phpmyadmin/config.inc.php
sudo sed -i "s/^\$cfg\['Servers'\]\[\$i\]\['password'\] = '';/\$cfg\['Servers'\]\[\$i\]\['password'\] = '$DB_ROOT_PASS';/" /etc/phpmyadmin/config.inc.php

# Restart Apache and MySQL
echo "[+] Restarting Apache and MySQL..."
sudo systemctl restart apache2
sudo systemctl restart mysql

# Download and Install WordPress
echo "[+] Downloading and installing WordPress..."
cd /var/www/html
sudo wget -q https://wordpress.org/latest.tar.gz
sudo tar -xzf latest.tar.gz
sudo mv wordpress wp_site
sudo rm latest.tar.gz
sudo chown -R www-data:www-data /var/www/html/wp_site
sudo chmod -R 755 /var/www/html/wp_site

# Configure Apache (HTTP and HTTPS)
echo "[+] Configuring Apache Virtual Hosts..."
sudo bash -c "cat > /etc/apache2/sites-available/$DOMAIN.conf <<EOF
<VirtualHost *:80>
    ServerName $DOMAIN
    DocumentRoot /var/www/html/wp_site
    <Directory /var/www/html/wp_site>
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF"

sudo bash -c "cat > /etc/apache2/sites-available/$DOMAIN-ssl.conf <<EOF
<VirtualHost *:443>
    ServerName $DOMAIN
    DocumentRoot /var/www/html/wp_site

    <Directory /var/www/html/wp_site>
        AllowOverride All
        Require all granted
    </Directory>

    SSLEngine on
    SSLCertificateFile /etc/letsencrypt/live/$DOMAIN/fullchain.pem
    SSLCertificateKeyFile /etc/letsencrypt/live/$DOMAIN/privkey.pem
    Include /etc/letsencrypt/options-ssl-apache.conf

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF"

sudo a2ensite $DOMAIN.conf
sudo a2ensite $DOMAIN-ssl.conf
sudo a2enmod rewrite
sudo a2enmod ssl
sudo systemctl restart apache2

# Enable SSL with Let's Encrypt
echo "[+] Generating SSL certificate with Let's Encrypt..."
sudo certbot --apache -d $DOMAIN --email $EMAIL --agree-tos --non-interactive --redirect || echo "[!] Let's Encrypt SSL setup skipped. Check logs if needed."

# Setup Automatic Renewal for Certbot
echo "[+] Setting up automatic renewal for Let's Encrypt SSL..."
echo "0 3 * * * root certbot renew --quiet" | sudo tee -a /etc/crontab > /dev/null

# Completion Message
echo "[+] Installation complete! Visit https://$DOMAIN to configure WordPress."
echo "[+] phpMyAdmin available at https://$DOMAIN/phpmyadmin"
