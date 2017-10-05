#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/english-braids.localhost.com/scripts
# $ ./update/10-prepare-composer.sh
CONFIG_M2_FILEPATH=`pwd`/config-m2.env
if [[ ! -f $CONFIG_M2_FILEPATH ]]; then
    echo "
#
# Could not detect config-m2.env.
# Create one first in $CONFIG_M2_FILEPATH
# Script cannot continue. Exiting now
#
"
exit
fi
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
        server_name www.$MAGENTO2_ENV_HOSTNAME $MAGENTO2_ENV_HOSTNAME;
        set \$MAGE_ROOT $MAGENTO2_ENV_WEBROOT;
        set \$MAGE_MODE developer;
        include $MAGENTO2_ENV_WEBROOT/nginx.conf.sample;
}
" >> /etc/nginx/sites-available/$MAGENTO2_ENV_HOSTNAME

sudo ln -s /etc/nginx/sites-available/$MAGENTO2_ENV_HOSTNAME /etc/nginx/sites-enabled/

sudo echo "127.0.0.1       www.$MAGENTO2_ENV_HOSTNAME $MAGENTO2_ENV_HOSTNAME" >> /etc/hosts

sudo service nginx restart
