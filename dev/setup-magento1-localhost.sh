#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/english-braids.localhost.com/scripts
# $ ./update/10-prepare-composer.sh
CONFIG_M2_FILEPATH=`pwd`/config-m1.env
PROJECT_ROOT_PATH=`pwd`
if [[ 'scripts' != ${PROJECT_ROOT_PATH: -7} ]]; then
    echo "
#
# The script detected you are running this script from an invalid location.
# Make sure you are running this script from the scripts directory.
# The script detected $PROJECT_ROOT_PATH
#
# Script cannot continue. Exiting now.
#"
exit
fi
if [[ ! -f $CONFIG_M2_FILEPATH ]]; then
    echo "
#
# Could not detect config-m1.env.
# Create one first in $PROJECT_ROOT_PATH/config-m1.env
# and make sure you are running this script from the scripts directory.
#
# Script cannot continue. Exiting now.
#"
exit
fi
set -a; . `pwd`/config-m1.env

#
# Script-specific logic starts here
#

# Cleanup
sudo rm -f /etc/nginx/sites-enabled/$MAGENTO1_ENV_HOSTNAME
sudo rm -f /etc/nginx/sites-available/$MAGENTO1_ENV_HOSTNAME
sudo rm -rf /etc/ssl/$MAGENTO1_ENV_HOSTNAME

# Generate self-signed SSL certificate
sudo mkdir -p /etc/ssl/$MAGENTO1_ENV_HOSTNAME
sudo openssl genrsa -out "/etc/ssl/$MAGENTO1_ENV_HOSTNAME/$MAGENTO1_ENV_HOSTNAME.key" 2048
echo "#
# Use *.$MAGENTO1_ENV_HOSTNAME as the common name to generate a wildcard certificate.
#"
sudo openssl req -new \
    -key "/etc/ssl/$MAGENTO1_ENV_HOSTNAME/$MAGENTO1_ENV_HOSTNAME.key" \
    -out "/etc/ssl/$MAGENTO1_ENV_HOSTNAME/$MAGENTO1_ENV_HOSTNAME.csr"
sudo openssl x509 -req -days 365 \
    -in "/etc/ssl/$MAGENTO1_ENV_HOSTNAME/$MAGENTO1_ENV_HOSTNAME.csr" \
    -signkey "/etc/ssl/$MAGENTO1_ENV_HOSTNAME/$MAGENTO1_ENV_HOSTNAME.key" \
    -out "/etc/ssl/$MAGENTO1_ENV_HOSTNAME/$MAGENTO1_ENV_HOSTNAME.crt"

# Generate nginx config file
sudo echo "# Uncomment this if you don't already have a fastcgi_backend defined
#upstream fastcgi_backend_php71 {
#        server  unix:/run/php/php7.1-fpm.sock;
#}

server {
    listen 80;
    listen 443 ssl;
    server_name $MAGENTO1_ENV_HOSTNAME www.$MAGENTO1_ENV_HOSTNAME;
    root $MAGENTO1_ENV_WEBROOT;

    # Important for VirtualBox
    sendfile off;

    ssl_certificate     /etc/ssl/$MAGENTO1_ENV_HOSTNAME/$MAGENTO1_ENV_HOSTNAME.crt;
    ssl_certificate_key /etc/ssl/$MAGENTO1_ENV_HOSTNAME/$MAGENTO1_ENV_HOSTNAME.key;

    # Handle requests to the root folder (e.g. When someone requests http://$MAGENTO1_ENV_HOSTNAME/)
    location / {
        index index.php;
        try_files \$uri \$uri/ @handler;
        expires 30d;
    }

    # Deny direct access to these folders
    location ^~ /app/                { deny all; }
    location ^~ /includes/           { deny all; }
    location ^~ /lib/                { deny all; }
    location ^~ /media/downloadable/ { deny all; }
    location ^~ /pkginfo/            { deny all; }
    location ^~ /report/config.xml   { deny all; }
    location ^~ /var/                { deny all; }

    location ~* (.+)\.(\d+)\.(js|css|png|jpg|jpeg|gif)\$ {
        try_files \$uri \$1.\$3;
    }

    # Ban any attempt to access dot files (e.g. .git, .htaccess, etc)
    location ~* (?:^|/)\. {
        deny all;
    }

    # Redirect requests for the webroot folder to /index.php
    location @handler {
        rewrite / /index.php;
    }

    # Remove trailing slash from requests for PHP files (e.g. /index.php/ > /index.php)
    location ~ .php/ {
        rewrite ^(.*.php)/ \$1 last;
    }

    # Handle requests for .php files
    location ~ \.php$ {
        if (!-e \$request_filename) { rewrite / /index.php last; }

        expires                 off;
        fastcgi_pass            fastcgi_backend_php71;
        fastcgi_read_timeout    3600;
        fastcgi_param           SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        include                 fastcgi_params;
    }
}
" >> /etc/nginx/sites-available/$MAGENTO1_ENV_HOSTNAME

sudo ln -s /etc/nginx/sites-available/$MAGENTO1_ENV_HOSTNAME /etc/nginx/sites-enabled/

sudo echo "127.0.0.1       $MAGENTO1_ENV_HOSTNAME www.$MAGENTO1_ENV_HOSTNAME" >> /etc/hosts

sudo service nginx restart