#!/bin/bash

# Define Variables (تعریف متغیرها)
DB_ROOT_PASS="rootpassword"  # MySQL root password (رمز عبور ریشه MySQL)
WP_DB_NAME="wordpress_db"  # WordPress database name (نام دیتابیس وردپرس)
WP_DB_USER="wordpress_user"  # WordPress database user (نام کاربری دیتابیس وردپرس)
WP_DB_PASS="wordpress_pass"  # WordPress database user password (رمز عبور کاربر دیتابیس وردپرس)
DOMAIN="example.com"  # Your website domain (دامنه وب‌سایت شما)
EMAIL="admin@example.com"  # Email for Let's Encrypt (ایمیل برای Let's Encrypt)

# Update the System (به‌روزرسانی سیستم)
echo "[+] Updating system... (در حال به‌روزرسانی سیستم...)"
sudo apt update && sudo apt upgrade -y

# Install Necessary Packages (نصب بسته‌های مورد نیاز)
echo "[+] Installing Apache, MySQL, PHP, and Certbot... (نصب Apache، MySQL، PHP و Certbot)"
sudo apt install -y apache2 mysql-server php libapache2-mod-php php-mysql php-cli php-curl php-zip php-xml unzip wget curl certbot python3-certbot-apache

# Configure MySQL (پیکربندی MySQL)
echo "[+] Configuring MySQL... (در حال پیکربندی MySQL...)"
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$DB_ROOT_PASS';"
sudo mysql -e "CREATE DATABASE $WP_DB_NAME;"
sudo mysql -e "CREATE USER '$WP_DB_USER'@'localhost' IDENTIFIED BY '$WP_DB_PASS';"
sudo mysql -e "GRANT ALL PRIVILEGES ON $WP_DB_NAME.* TO '$WP_DB_USER'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"

# Download and Install WordPress (دانلود و نصب وردپرس)
echo "[+] Downloading and installing WordPress... (دانلود و نصب وردپرس...)"
cd /var/www/html
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzf latest.tar.gz
sudo mv wordpress wp_site
sudo rm latest.tar.gz
sudo chown -R www-data:www-data /var/www/html/wp_site

# Configure Apache (پیکربندی Apache)
echo "[+] Configuring Apache... (در حال پیکربندی Apache...)"
sudo bash -c "cat > /etc/apache2/sites-available/$DOMAIN.conf <<EOF
<VirtualHost *:80>
    ServerName $DOMAIN
    DocumentRoot /var/www/html/wp_site
    <Directory /var/www/html/wp_site>
        AllowOverride All
        Require all granted
    </Directory>
</VirtualHost>
EOF"

sudo a2ensite $DOMAIN.conf
sudo a2enmod rewrite
sudo systemctl restart apache2

# Enable SSL with Let's Encrypt (فعال‌سازی SSL با Let's Encrypt)
echo "[+] Generating SSL certificate with Let's Encrypt... (ایجاد گواهینامه SSL با Let's Encrypt...)"
sudo certbot --apache -d $DOMAIN --email $EMAIL --agree-tos --non-interactive

# Completion Message (پیام پایان فرآیند)
echo "[+] Installation complete! Visit https://$DOMAIN to configure WordPress. (نصب کامل شد! برای پیکربندی وردپرس به https://$DOMAIN مراجعه کنید.)"
