#!/bin/bash
sudo apt update && sudo apt upgrade -y

sudo apt install -y software-properties-common

sudo add-apt-repository ppa:ondrej/php -y
sudo apt update

# PHP 7.4 
sudo apt install -y php7.4 php7.4-cli php7.4-common php7.4-mysql php7.4-xml php7.4-curl \
php7.4-mbstring php7.4-zip php7.4-bcmath php7.4-json php7.4-soap php7.4-intl php7.4-ldap \
php7.4-odbc php7.4-pspell php7.4-readline php7.4-sqlite3 php7.4-gd

sudo a2dismod php8.1
sudo a2enmod php7.4
sudo systemctl restart apache2

sudo apt install -y wget build-essential apache2 mariadb-server mariadb-client \
php7.4 php7.4-cli php7.4-common php7.4-mysql php7.4-xml php7.4-curl \
php7.4-mbstring php7.4-zip php7.4-bcmath php7.4-json php7.4-soap php7.4-intl php7.4-ldap \
php7.4-odbc php7.4-pspell php7.4-readline php7.4-sqlite3 php7.4-gd \
curl sox git unixodbc uuid uuid-dev libsqlite3-dev sqlite3 bison subversion \
libjansson-dev libxml2-dev libcurl4-openssl-dev libncurses5-dev libnewt-dev \
libtool-bin python3-dev libedit-dev libssl-dev lsb-release \
autoconf automake libpopt-dev libiksemel-dev libspandsp-dev \
libtiff-dev libgsm1-dev libspandsp-dev libgsm1-dev libvorbis-dev libltdl-dev asterisk odbc-mariadb nodejs npm

sudo systemctl start mariadb
sudo mysql_secure_installation

sudo wget http://downloads.asterisk.org/pub/telephony/asterisk/asterisk-18-current.tar.gz
sudo tar zxvf asterisk-18-current.tar.gz
cd asterisk-18*/
sudo contrib/scripts/install_prereq install
sudo ./configure
sudo make menuselect
sudo make
sudo make install
sudo make samples
sudo make config
sudo ldconfig
sudo systemctl start asterisk
sudo systemctl enable asterisk

sudo wget https://github.com/FreePBX/framework/archive/release/16.0.tar.gz
sudo tar zxvf 16.0.tar.gz
cd framework-release-16.0
sudo ./start_asterisk start
sudo ./install -n --dbuser root --dbpass <DB_PASSWORD> --webroot=/var/www/html


sudo chown -R www-data:www-data /var/www/html
sudo chmod -R 755 /var/www/html

sudo bash -c 'cat > /etc/apache2/sites-available/freepbx.conf <<EOF
<VirtualHost *:80>
    ServerAdmin webmaster@localhost
    DocumentRoot /var/www/html
    <Directory />
        Options FollowSymLinks
        AllowOverride None
    </Directory>
    <Directory /var/www/html/>
        Options Indexes FollowSymLinks MultiViews
        AllowOverride All
        Require all granted
    </Directory>
    ErrorLog \${APACHE_LOG_DIR}/error.log
    CustomLog \${APACHE_LOG_DIR}/access.log combined
</VirtualHost>
EOF'

sudo a2ensite freepbx.conf
sudo a2enmod rewrite
sudo systemctl restart apache2
sudo usermod -aG www-data asterisk
sudo fwconsole chown
sudo sed -i 's/www-data/asterisk/' /etc/apache2/envvars

sudo a2dissite 000-default.conf
sudo systemctl restart apache2


echo "Installation completed. "
