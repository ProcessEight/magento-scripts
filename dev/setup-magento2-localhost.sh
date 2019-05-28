#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/your-project.local/scripts
# $ ./update/10-prepare-composer.sh
CONFIG_M2_FILEPATH=`pwd`/config-m2.env
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
# Could not detect config-m2.env.
# Create one first in $PROJECT_ROOT_PATH/config-m2.env
# and make sure you are running this script from the scripts directory.
#
# Script cannot continue. Exiting now.
#"
exit
fi
set -a; . `pwd`/config-m2.env

#
# Script-specific logic starts here
#

# Cleanup
sudo rm -f /etc/nginx/sites-enabled/$MAGENTO2_ENV_HOSTNAME
sudo rm -f /etc/nginx/sites-available/$MAGENTO2_ENV_HOSTNAME

echo "
#
# Creating new nginx vhost...
#
"
sudo cp -f $MAGENTO2_ENV_WEBROOT/nginx.conf.sample $MAGENTO2_ENV_WEBROOT/nginx.conf.local
nano $MAGENTO2_ENV_WEBROOT/nginx.conf.local

sudo echo "# Uncomment this if you don't already have a fastcgi_backend defined
#upstream fastcgi_backend {
#        server  unix:/run/php/php7.2-fpm.sock;
#}

server {
        listen 80;
        server_name www.$MAGENTO2_ENV_HOSTNAME $MAGENTO2_ENV_HOSTNAME;
        set \$MAGE_ROOT $MAGENTO2_ENV_WEBROOT;
        set \$MAGE_MODE developer;
        include $MAGENTO2_ENV_WEBROOT/nginx.conf.local;
}
" >> /etc/nginx/sites-available/$MAGENTO2_ENV_HOSTNAME

echo "
#
# Sym-linking vhost to /etc/nginx/sites-enabled...
#
"
sudo ln -s /etc/nginx/sites-available/$MAGENTO2_ENV_HOSTNAME /etc/nginx/sites-enabled/

echo "
#
# Adding entry to /etc/hosts...
#
"
sudo echo "127.0.0.1       www.$MAGENTO2_ENV_HOSTNAME $MAGENTO2_ENV_HOSTNAME" >> /etc/hosts

echo "
#
# Restarting nginx...
#
"
sudo service nginx restart

echo "
#
# Setup complete. You should now be able to visit www.$MAGENTO2_ENV_HOSTNAME or $MAGENTO2_ENV_HOSTNAME in a browser.
#
"