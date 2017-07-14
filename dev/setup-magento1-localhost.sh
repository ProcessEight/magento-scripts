#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/english-braids.localhost.com/scripts
# $ ./update/10-prepare-composer.sh
CONFIG_M1_FILEPATH=`pwd`/config-m1.env
if [[ ! -f $CONFIG_M1_FILEPATH ]]; then
    echo "
#
# Could not detect config-m1.env.
# Create one first in $CONFIG_M1_FILEPATH
# Script cannot continue. Exiting now
#
"
    exit
fi
set -a; . `pwd`/config-m1.env

# Cleanup
sudo rm -f /etc/nginx/sites-enabled/$MAGENTO1_ENV_HOSTNAME
sudo rm -f /etc/nginx/sites-available/$MAGENTO1_ENV_HOSTNAME

sudo echo "# Uncomment this if you don't already have a fastcgi_backend defined
#upstream fastcgi_backend {
#        server  unix:/run/php/php7.0-fpm.sock;
#}

server {
    listen 80;
    server_name $MAGENTO1_ENV_HOSTNAME www.$MAGENTO1_ENV_HOSTNAME;
    root $MAGENTO1_ENV_WEBROOT;

    # Important for VirtualBox
    sendfile off;

    location / {
        index index.php;
        try_files \$uri \$uri/ @handler;
        expires 30d;
    }

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

    location  /. {
        return 404;
    }

    location @handler {
        rewrite / /index.php;
    }

    location ^~ /git/ {
        rewrite / /git.php;
    }

    location ~ .php/ {
        rewrite ^(.*.php)/ \$1 last;
    }

    location ~ \.php$ {
        if (!-e \$request_filename) { rewrite / /index.php last; }

        expires                 off;
        #fastcgi_pass           phpupstream;
        fastcgi_pass            unix:/run/php/php7.0-fpm.sock;
        fastcgi_read_timeout    3600;
        fastcgi_param           SCRIPT_FILENAME \$document_root\$fastcgi_script_name;
        fastcgi_param           MAGE_IS_DEVELOPER_MODE 1;
        include                 fastcgi_params;
    }
}
" >> /etc/nginx/sites-available/$MAGENTO1_ENV_HOSTNAME

sudo ln -s /etc/nginx/sites-available/$MAGENTO1_ENV_HOSTNAME /etc/nginx/sites-enabled/

sudo echo "127.0.0.1       $MAGENTO1_ENV_HOSTNAME www.$MAGENTO1_ENV_HOSTNAME" >> /etc/hosts

sudo service nginx restart