# WordPress Auto-Installer Script

This script automates the installation and configuration of a **WordPress** website with **Apache**, **MySQL**, **PHP**, **phpMyAdmin**, and **Let's Encrypt SSL certificate** on an **Ubuntu server**.

## Features
- Automatic installation of **Apache**, **MySQL**, **PHP**, and **phpMyAdmin**
- Secure MySQL database and user creation for WordPress
- Automated WordPress download, setup, and permissions
- Configuration of Apache virtual hosts (HTTP & HTTPS)
- Automatic issuance and renewal of **Let's Encrypt SSL certificates**
- Redirects all HTTP traffic to HTTPS after SSL setup

## Prerequisites
- A **clean Ubuntu server** (20.04/22.04 recommended)
- A **registered domain name** pointing to your server's IP
- Root or sudo access to the server

## Installation
### 1️⃣ Download and Run the Script
```bash
wget https://github.com/khalili-mohammad/Youtube/edit/main/Wordpress/Wordpress%20%2B%20Domain/wordpress.sh
chmod +x wordpress.sh
sudo ./wordpress.sh
```

### 2️⃣ Provide Necessary Details
Before running, **edit the script** to update the following variables:
```bash
DB_ROOT_PASS="your_database_root_password"
WP_DB_NAME="your_wordpress_database_name"
WP_DB_USER="your_wordpress_user"
WP_DB_PASS="your_wordpress_password"
DOMAIN="yourdomain.com"
EMAIL="your_email@example.com"
```

## Post-Installation Steps
1. Open **https://yourdomain.com** in your browser.
2. Follow the WordPress installation steps (choose language, set username/password, etc.).
3. Visit **https://yourdomain.com/phpmyadmin** to manage the database.

## Troubleshooting
- **Apache fails to start?**
  ```bash
  sudo journalctl -xeu apache2.service | tail -n 20
  ```
- **Check Let's Encrypt logs:**
  ```bash
  sudo cat /var/log/letsencrypt/letsencrypt.log
  ```
- **Renew SSL manually:**
  ```bash
  sudo certbot renew --force-renewal
  ```

---

# اسکریپت نصب خودکار وردپرس

این اسکریپت فرآیند نصب و پیکربندی **وردپرس** را به صورت خودکار انجام می‌دهد و شامل **Apache، MySQL، PHP، phpMyAdmin** و **گواهینامه امنیتی Let's Encrypt** است.

## ویژگی‌ها
- نصب خودکار **Apache، MySQL، PHP، phpMyAdmin**
- ایجاد خودکار پایگاه داده **MySQL** و کاربر **WordPress**
- دانلود و تنظیم خودکار وردپرس با دسترسی‌های مناسب
- تنظیم میزبان‌های مجازی **Apache** برای HTTP و HTTPS
- صدور و تمدید خودکار **گواهی امنیتی Let's Encrypt SSL**
- هدایت تمام ترافیک **HTTP** به **HTTPS** پس از نصب موفقیت‌آمیز SSL

## پیش‌نیازها
- یک سرور **Ubuntu** تازه نصب‌شده (**20.04 یا 22.04 پیشنهاد می‌شود**)
- یک **نام دامنه** که به آی‌پی سرور اشاره کند
- دسترسی **ریشه (Root) یا sudo** به سرور

## نصب
### 1️⃣ دانلود و اجرای اسکریپت
```bash
wget https://github.com/khalili-mohammad/Youtube/edit/main/Wordpress/Wordpress%20%2B%20Domain/wordpress.sh
chmod +x wordpress.sh
sudo ./wordpress.sh
```

### 2️⃣ تغییر متغیرهای مورد نیاز
قبل از اجرا، **فایل اسکریپت را ویرایش کنید** و اطلاعات زیر را تغییر دهید:
```bash
DB_ROOT_PASS="رمز عبور پایگاه داده ریشه"
WP_DB_NAME="نام پایگاه داده وردپرس"
WP_DB_USER="نام کاربری وردپرس"
WP_DB_PASS="رمز عبور وردپرس"
DOMAIN="نام دامنه شما"
EMAIL="ایمیل شما"
```

## مراحل بعد از نصب
1. مرورگر را باز کرده و **https://yourdomain.com** را وارد کنید.
2. مراحل نصب وردپرس را طی کنید (انتخاب زبان، تنظیم نام کاربری/رمز عبور، و غیره).
3. از **https://yourdomain.com/phpmyadmin** برای مدیریت پایگاه داده استفاده کنید.

## رفع مشکلات
- **اگر Apache اجرا نمی‌شود:**
  ```bash
  sudo journalctl -xeu apache2.service | tail -n 20
  ```
- **بررسی لاگ‌های Let's Encrypt:**
  ```bash
  sudo cat /var/log/letsencrypt/letsencrypt.log
  ```
- **تمدید دستی گواهینامه SSL:**
  ```bash
  sudo certbot renew --force-renewal
  ```

