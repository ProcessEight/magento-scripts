#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/english-braids.localhost.com/scripts
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

cd $MAGENTO2_ENV_WEBROOT

echo "
#
# Manually removing cached and generated backend files
#
"
echo "Cleaning...
$MAGENTO2_ENV_WEBROOT/var/cache/*
$MAGENTO2_ENV_WEBROOT/var/generation/*
$MAGENTO2_ENV_WEBROOT/generated/*
$MAGENTO2_ENV_WEBROOT/var/di/*
$MAGENTO2_ENV_WEBROOT/var/tmp/*
$MAGENTO2_ENV_WEBROOT/var/page_cache/*"
rm -rf $MAGENTO2_ENV_WEBROOT/var/cache/*
rm -rf $MAGENTO2_ENV_WEBROOT/var/generation/*
rm -rf $MAGENTO2_ENV_WEBROOT/generated/*
rm -rf $MAGENTO2_ENV_WEBROOT/var/di/*
rm -rf $MAGENTO2_ENV_WEBROOT/var/tmp/*
rm -rf $MAGENTO2_ENV_WEBROOT/var/page_cache/*
echo "Cleaning automated testing sandbox files "
rm -rf $MAGENTO2_ENV_WEBROOT/dev/tests/integration/tmp/sandbox-*
rm -rf $MAGENTO2_ENV_WEBROOT/dev/tests/unit/tmp/sandbox-*
#echo "Clearing all caches in redis for project "
#redis-cli -n 2 flushdb
#redis-cli -n 3 flushdb
echo "Skipping redis flushdb "

echo "
#
# Running bin/magento cache:clean
# Running bin/magento cache:flush
#
"
/var/www/html/magento2-deployment/dev/n98-magerun2-no-xdebug.sh cache:clean
/var/www/html/magento2-deployment/dev/n98-magerun2-no-xdebug.sh cache:flush

echo "
#
# Restarting PHP 7.1
#
"
sudo service php7.1-fpm restart

echo "
#
# Running composer install
#
"
cd ../htdocs && $MAGENTO2_ENV_COMPOSERCOMMAND install

echo "
#
# Running bin/magento app:config:import
#
"
/var/www/html/magento2-deployment/dev/n98-magerun2-no-xdebug.sh app:config:import

echo "
#
# Running bin/magento cache:enable
#
"
/var/www/html/magento2-deployment/dev/n98-magerun2-no-xdebug.sh cache:enable

echo "
#
# Running bin/magento setup:upgrade
#
"
/var/www/html/magento2-deployment/dev/n98-magerun2-no-xdebug.sh setup:upgrade

echo "
#
# Running bin/magento sys:setup:downgrade-versions
#
"
/var/www/html/magento2-deployment/dev/n98-magerun2-no-xdebug.sh sys:setup:downgrade-versions

echo "
#
# All done!
#
"
