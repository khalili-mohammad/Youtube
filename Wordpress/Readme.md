# WordPress Installation Script (English + Persian)

This script automates the installation of **WordPress** on an **Ubuntu** server. It configures Apache, MySQL, PHP, phpMyAdmin

اسکریپت زیر به صورت خودکار **وردپرس** را بر روی **اوبونتو** نصب کرده، Apache، MySQL، PHP، phpMyAdmin را تنظیم کرده

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
echo "[+] Installing Apache, MySQL, PHP, phpMyAdmin, and Certbot... (نصب Apache، MySQL، PHP، phpMyAdmin و Certbot)"
sudo apt install -y apache2 mysql-server php libapache2-mod-php php-mysql php-cli php-curl php-zip php-xml unzip wget curl certbot python3-certbot-apache phpmyadmin
```
- Installs **Apache**, **MySQL**, **PHP**, **phpMyAdmin**, and **Certbot**.
- **Apache**، **MySQL**، **PHP**، **phpMyAdmin** و **Certbot** را نصب می‌کند.

### 3. Configure MySQL (پیکربندی MySQL)
```bash
echo "[+] Configuring MySQL... (در حال پیکربندی MySQL...)"
sudo mysql -e "ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$DB_ROOT_PASS';"
sudo mysql -e "CREATE DATABASE $WP_DB_NAME;"
sudo mysql -e "CREATE USER '$WP_DB_USER'@'localhost' IDENTIFIED BY '$WP_DB_PASS';"
sudo mysql -e "GRANT ALL PRIVILEGES ON $WP_DB_NAME.* TO '$WP_DB_USER'@'localhost';"
sudo mysql -e "FLUSH PRIVILEGES;"
```
- Sets up a **WordPress** database and user.
- یک دیتابیس و کاربر مخصوص **وردپرس** ایجاد می‌کند.

### 4. Configure phpMyAdmin (پیکربندی phpMyAdmin)
```bash
echo "[+] Configuring phpMyAdmin... (در حال پیکربندی phpMyAdmin...)"
sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin
sudo mysql -e "ALTER USER 'phpmyadmin'@'localhost' IDENTIFIED BY '$DB_ROOT_PASS';"
```
- Creates a symbolic link to make phpMyAdmin accessible.
- Sets a password for the `phpmyadmin` user.
- **لینک phpMyAdmin را ایجاد کرده و رمز عبور را تنظیم می‌کند.**

### 5. Download and Install WordPress (دانلود و نصب وردپرس)
```bash
echo "[+] Downloading and installing WordPress... (دانلود و نصب وردپرس...)"
cd /var/www/html
sudo wget https://wordpress.org/latest.tar.gz
sudo tar -xzf latest.tar.gz
sudo mv wordpress wp_site
sudo rm latest.tar.gz
sudo chown -R www-data:www-data /var/www/html/wp_site
```
- Downloads and extracts WordPress files.
- فایل‌های **وردپرس** را دانلود و از حالت فشرده خارج می‌کند.

### 6. Configure Apache (پیکربندی Apache)
```bash
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
```
- Creates a VirtualHost configuration file for Apache.
- یک فایل **پیکربندی** برای سرور **آپاچی** ایجاد می‌کند.

### 7. Enable SSL with Let's Encrypt (فعال‌سازی SSL با Let's Encrypt)
```bash
echo "[+] Generating SSL certificate with Let's Encrypt... (ایجاد گواهینامه SSL با Let's Encrypt...)"
sudo certbot --apache -d $DOMAIN --email $EMAIL --agree-tos --non-interactive
```
- Installs a **free SSL certificate** for your domain.
- یک **گواهینامه SSL رایگان** برای دامنه شما نصب می‌کند.

### 8. Completion Message (پیام پایان فرآیند)
```bash
echo "[+] Installation complete! Visit https://$DOMAIN to configure WordPress. (نصب کامل شد! برای پیکربندی وردپرس به https://$DOMAIN مراجعه کنید.)"
echo "[+] phpMyAdmin available at http://$DOMAIN/phpmyadmin"
```
- Displays a completion message after installation.
- پیامی برای تکمیل فرآیند نمایش می‌دهد.

---

## Usage (نحوه استفاده از اسکریپت)
1. Clone or download the script to your server.
2. Edit the variables **DOMAIN**, **EMAIL**, and database credentials.
3. Run the script with:

```bash
chmod +x install_wordpress.sh
sudo ./install_wordpress.sh
```

1. اسکریپت را روی سرور دانلود کنید.
2. مقادیر **DOMAIN**، **EMAIL** و تنظیمات دیتابیس را تغییر دهید.
3. اسکریپت را اجرا کنید:

```bash
chmod +x install_wordpress.sh
sudo ./install_wordpress.sh
```

---

## License (لایسنس)
This script is open-source and released under the MIT License.

این اسکریپت **متن باز** بوده و تحت مجوز **MIT** منتشر شده است.
