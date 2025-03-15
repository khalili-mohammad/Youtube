#!/bin/bash

# Define Variables
DB_ROOT_PASS="rootpassword"
WP_DB_NAME="wordpress_db"
WP_DB_USER="wordpress_user"
WP_DB_PASS="wordpress_pass"
DOMAIN="example.com"  # Set your Domain or Subdomain
EMAIL="example@example.com"

# Funktion zur Fehlerprüfung
check_success() {
    if [ $? -ne 0 ]; then
        echo "[ERROR] $1 fehlgeschlagen. Überprüfe die Logs."
        exit 1
    fi
}

# Update System
echo "[+] Updating system..."
sudo apt update && sudo apt upgrade -y

# Install Necessary Packages
echo "[+] Installing Apache, MySQL, PHP, Certbot, and phpMyAdmin..."
sudo apt install -y apache2 mysql-server php libapache2-mod-php php-mysql php-cli php-curl php-zip php-xml unzip wget curl certbot python3-certbot-apache phpmyadmin
check_success "Package installation"

# Configure MySQL
echo "[+] Configuring MySQL..."
sudo systemctl start mysql
sudo systemctl enable mysql
check_success "MySQL start"

sudo mysql -u root -p"$DB_ROOT_PASS" <<EOF
CREATE DATABASE IF NOT EXISTS $WP_DB_NAME;
CREATE USER IF NOT EXISTS '$WP_DB_USER'@'localhost' IDENTIFIED BY '$WP_DB_PASS';
GRANT ALL PRIVILEGES ON $WP_DB_NAME.* TO '$WP_DB_USER'@'localhost';
ALTER USER 'phpmyadmin'@'localhost' IDENTIFIED BY '$DB_ROOT_PASS';
ALTER USER 'root'@'localhost' IDENTIFIED WITH mysql_native_password BY '$DB_ROOT_PASS';
GRANT ALL PRIVILEGES ON *.* TO 'root'@'localhost' WITH GRANT OPTION;
FLUSH PRIVILEGES;
EOF
check_success "MySQL configuration"

# Configure phpMyAdmin
echo "[+] Configuring phpMyAdmin..."
if [ ! -L "/var/www/html/phpmyadmin" ]; then
    sudo ln -s /usr/share/phpmyadmin /var/www/html/phpmyadmin
fi

# Ensure WordPress directory exists
echo "[+] Ensuring WordPress directory exists..."
sudo mkdir -p /var/www/html/wp_site
sudo chown -R www-data:www-data /var/www/html/wp_site
sudo chmod -R 755 /var/www/html/wp_site

# Restart Apache and MySQL
echo "[+] Restarting Apache and MySQL..."
sudo systemctl restart apache2
check_success "Apache restart"
sudo systemctl restart mysql
check_success "MySQL restart"

# Download and Install WordPress
echo "[+] Downloading and installing WordPress..."
cd /var/www/html
sudo wget -q https://wordpress.org/latest.tar.gz
check_success "WordPress download"
sudo tar -xzf latest.tar.gz
sudo mv wordpress/* wp_site/
sudo rm -rf latest.tar.gz wordpress
sudo chown -R www-data:www-data /var/www/html/wp_site
sudo chmod -R 755 /var/www/html/wp_site
check_success "WordPress installation"

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
    
    # Automatische HTTPS-Umleitung (wird später aktiviert)
    RewriteEngine on
    RewriteCond %{HTTPS} !=on
    RewriteRule ^(.*)$ https://$DOMAIN\$1 [R=301,L]

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

    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF"

# Aktivieren von Apache2-Modulen und VirtualHosts
sudo a2ensite $DOMAIN.conf
sudo a2ensite $DOMAIN-ssl.conf
sudo a2enmod rewrite
sudo a2enmod ssl
sudo systemctl stop apache2

# Prüfen, ob bereits ein SSL-Zertifikat existiert
if [ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    echo "[+] SSL-Zertifikat existiert bereits. Prüfe, ob eine Erneuerung nötig ist..."
    
    if sudo openssl x509 -checkend 2592000 -noout -in /etc/letsencrypt/live/$DOMAIN/fullchain.pem; then
        echo "[+] Zertifikat ist noch gültig. Keine Erneuerung erforderlich."
    else
        echo "[+] Zertifikat läuft bald ab. Erneuere Zertifikat..."
        sudo certbot renew --quiet
        check_success "SSL-Zertifikat erneuert"
    fi
else
    echo "[+] Kein SSL-Zertifikat gefunden. Erstelle ein neues Zertifikat..."
    sudo a2dissite $DOMAIN-ssl.conf
    
    sudo certbot certonly --standalone -d $DOMAIN --email $EMAIL --agree-tos --non-interactive
    if [ $? -ne 0 ]; then
        echo "[!] Let's Encrypt SSL-Setup fehlgeschlagen. Starte Apache ohne SSL..."
    else
        echo "[+] SSL-Zertifikat erfolgreich erstellt."
        sudo a2ensite $DOMAIN-ssl.conf
    fi
fi

# Apache2 neu starten
sudo systemctl start apache2
sudo systemctl restart apache2
check_success "Restarting Apache after SSL setup"

# Falls SSL erfolgreich installiert wurde, aktiviere HTTPS-Redirect in Apache
if [ -f "/etc/letsencrypt/live/$DOMAIN/fullchain.pem" ]; then
    echo "[+] SSL erfolgreich eingerichtet! Erzwinge HTTPS-Umleitung..."
    sudo sed -i '/RewriteCond %{HTTPS} !=on/,+1 s/^#//' /etc/apache2/sites-available/$DOMAIN.conf
    sudo systemctl restart apache2
fi

# Automatische Erneuerung für Let's Encrypt einrichten (Falls nicht vorhanden)
if ! crontab -l | grep -q "certbot renew"; then
    echo "[+] Automatische Erneuerung für Let's Encrypt einrichten..."
    (crontab -l ; echo "0 3 * * * certbot renew --quiet") | crontab -
fi

# Abschlussmeldung
echo "[+] Installation abgeschlossen! Besuche https://$DOMAIN zur WordPress-Konfiguration."
echo "[+] phpMyAdmin verfügbar unter https://$DOMAIN/phpmyadmin"
