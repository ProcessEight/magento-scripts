#!/usr/bin/env bash
set -a; . `pwd`/config-m2.env

# Cleanup
sudo rm -f /etc/nginx/sites-enabled/$MAGENTO2_ENV_HOSTNAME
sudo rm -f /etc/nginx/sites-available/$MAGENTO2_ENV_HOSTNAME

sudo echo "# Uncomment this if you don't already have a fastcgi_backend defined
#upstream fastcgi_backend {
#        server  unix:/run/php/php7.0-fpm.sock;
#}

server {
    listen 80;
    server_name $MAGENTO2_ENV_HOSTNAME;
    root $MAGENTO2_ENV_WEBROOT;

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
" >> /etc/nginx/sites-available/$MAGENTO2_ENV_HOSTNAME

sudo ln -s /etc/nginx/sites-available/$MAGENTO2_ENV_HOSTNAME /etc/nginx/sites-enabled/

sudo echo "127.0.0.1       $MAGENTO2_ENV_HOSTNAME" >> /etc/hosts

sudo service nginx restart