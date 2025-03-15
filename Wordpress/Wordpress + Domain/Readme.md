# WordPress Installation Script (English + Persian)

This script automates the installation of **WordPress** on an **Ubuntu** server. It configures Apache, MySQL, PHP, and sets up an SSL certificate using **Let's Encrypt**.

اسکریپت زیر به صورت خودکار **وردپرس** را بر روی **اوبونتو** نصب کرده، Apache، MySQL، PHP را تنظیم کرده و یک گواهینامه **SSL** با استفاده از **Let's Encrypt** ایجاد می‌کند.

---

## Prerequisites (پیش‌نیازها)
- A fresh Ubuntu server.
- A registered domain pointing to your server.
- A user with sudo privileges.

- یک سرور اوبونتو تازه نصب شده.
- یک دامنه ثبت شده که به سرور شما اشاره دارد.
- یک کاربر با دسترسی **sudo**.

---

## Steps (مراحل اجرای اسکریپت)

### 1. Update the System (به‌روزرسانی سیستم)
```bash
echo "[+] Updating system... (در حال به‌روزرسانی سیستم...)"
sudo apt update && sudo apt upgrade -y
```
- Updates all installed packages to the latest version.
- بسته‌های نصب شده را به آخرین نسخه به‌روزرسانی می‌کند.

### 2. Install Required Packages (نصب بسته‌های مورد نیاز)
```bash
echo "[+] Installing Apache, MySQL, PHP, Certbot, and phpMyAdmin... (نصب Apache، MySQL، PHP، Certbot و phpMyAdmin)"
sudo apt install -y apache2 mysql-server php libapache2-mod-php php-mysql php-cli php-curl php-zip php-xml unzip wget curl certbot python3-certbot-apache phpmyadmin
```
- Installs **Apache**, **MySQL**, **PHP**, **Certbot**, and **phpMyAdmin**.
- **Apache**، **MySQL**، **PHP**، **Certbot** و **phpMyAdmin** را نصب می‌کند.

### 3. Configure MySQL (پیکربندی MySQL)
```bash
echo "[+] Configuring MySQL... (در حال پیکربندی MySQL...)"
sudo mysql -u root -p"$DB_ROOT_PASS" <<EOF
CREATE DATABASE IF NOT EXISTS $WP_DB_NAME;
CREATE USER IF NOT EXISTS '$WP_DB_USER'@'localhost' IDENTIFIED BY '$WP_DB_PASS';
GRANT ALL PRIVILEGES ON $WP_DB_NAME.* TO '$WP_DB_USER'@'localhost';
ALTER USER 'phpmyadmin'@'localhost' IDENTIFIED BY '$DB_ROOT_PASS';
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$DB_ROOT_PASS';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
```
- Sets up a **WordPress** database and user.
- یک دیتابیس و کاربر مخصوص **وردپرس** ایجاد می‌کند.

### 4. Download and Install WordPress (دانلود و نصب وردپرس)
```bash
echo "[+] Downloading and installing WordPress... (دانلود و نصب وردپرس...)"
cd /var/www/html
sudo wget -q https://wordpress.org/latest.tar.gz
sudo tar -xzf latest.tar.gz
sudo mv wordpress wp_site
sudo rm latest.tar.gz
sudo chown -R www-data:www-data /var/www/html/wp_site
sudo chmod -R 755 /var/www/html/wp_site
```
- Downloads and extracts WordPress files.
- فایل‌های **وردپرس** را دانلود و از حالت فشرده خارج می‌کند.

### 5. Configure Apache (پیکربندی Apache)
```bash
echo "[+] Configuring Apache Virtual Hosts... (در حال پیکربندی Apache...)"
sudo a2enmod rewrite ssl
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
</VirtualHost>
EOF"

sudo a2ensite $DOMAIN.conf
sudo a2ensite $DOMAIN-ssl.conf
sudo systemctl restart apache2
```
- Creates a VirtualHost configuration file for both HTTP and HTTPS.
- یک فایل **پیکربندی** برای سرور **آپاچی** برای هر دو پروتکل HTTP و HTTPS ایجاد می‌کند.

### 6. Enable SSL with Let's Encrypt (فعال‌سازی SSL با Let's Encrypt)
```bash
echo "[+] Generating SSL certificate with Let's Encrypt... (ایجاد گواهینامه SSL با Let's Encrypt...)"
sudo certbot --apache -d $DOMAIN --email $EMAIL --agree-tos --non-interactive --redirect
```
- Installs a **free SSL certificate** for your domain.
- یک **گواهینامه SSL رایگان** برای دامنه شما نصب می‌کند.

### 7. Setup Automatic SSL Renewal (فعال‌سازی تمدید خودکار SSL)
```bash
echo "[+] Setting up automatic renewal for Let's Encrypt SSL... (تنظیم تمدید خودکار گواهینامه SSL...)"
echo "0 3 * * * root certbot renew --quiet" | sudo tee -a /etc/crontab > /dev/null
```
- Ensures SSL certificate is renewed automatically.
- اطمینان حاصل می‌کند که گواهینامه SSL به‌صورت خودکار تمدید شود.

### 8. Completion Message (پیام پایان فرآیند)
```bash
echo "[+] Installation complete! Visit https://$DOMAIN to configure WordPress. (نصب کامل شد! برای پیکربندی وردپرس به https://$DOMAIN مراجعه کنید.)"
```

---

## License (لایسنس)
This script is open-source and released under the MIT License.

این اسکریپت **متن باز** بوده و تحت مجوز **MIT** منتشر شده است.
