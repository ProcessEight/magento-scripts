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

cd $MAGENTO2_ENV_WEBROOT

echo "
#
# Cleaning backend files...
#
"
echo "
$MAGENTO2_ENV_WEBROOT/generated/*
$MAGENTO2_ENV_WEBROOT/var/cache/*
$MAGENTO2_ENV_WEBROOT/var/page_cache/*
$MAGENTO2_ENV_WEBROOT/var/generation/*
$MAGENTO2_ENV_WEBROOT/var/di/*
$MAGENTO2_ENV_WEBROOT/var/tmp/*
"
rm -rf $MAGENTO2_ENV_WEBROOT/generated/*
rm -rf $MAGENTO2_ENV_WEBROOT/var/cache/*
rm -rf $MAGENTO2_ENV_WEBROOT/var/page_cache/*
rm -rf $MAGENTO2_ENV_WEBROOT/var/generation/*
rm -rf $MAGENTO2_ENV_WEBROOT/var/di/*
rm -rf $MAGENTO2_ENV_WEBROOT/var/tmp/*
echo "
#
# Cleaning automated testing sandbox files...
#
"
rm -rf $MAGENTO2_ENV_WEBROOT/dev/tests/integration/tmp/sandbox-*
rm -rf $MAGENTO2_ENV_WEBROOT/dev/tests/unit/tmp/sandbox-*

echo "
#
# Clearing all Redis caches in project...
# (do make sure the redis db numbers are correct)
#
"
redis-cli -n 2 flushdb
redis-cli -n 3 flushdb
#echo "Skipping redis flushdb "

echo "
#
# Running bin/magento cache:clean
# Running bin/magento cache:flush
#
"
$MAGENTO2_ENV_PHPCOMMAND -f bin/magento cache:clean
$MAGENTO2_ENV_PHPCOMMAND -f bin/magento cache:flush

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
cd $MAGENTO2_ENV_WEBROOT && $MAGENTO2_ENV_COMPOSERCOMMAND install

echo "
#
# Running $MAGENTO2_ENV_PHPCOMMAND bin/magento app:config:import
#
"
$MAGENTO2_ENV_PHPCOMMAND -f bin/magento app:config:import

echo "
#
# Running $MAGENTO2_ENV_PHPCOMMAND bin/magento setup:upgrade
#
"
$MAGENTO2_ENV_PHPCOMMAND -f bin/magento setup:upgrade

echo "
#
# Running $MAGENTO2_ENV_PHPCOMMAND /var/www/html/n98-magerun2.phar sys:setup:downgrade-versions
#
"
$MAGENTO2_ENV_PHPCOMMAND /var/www/html/n98-magerun2.phar sys:setup:downgrade-versions

echo "
#
# All done!
#
"
