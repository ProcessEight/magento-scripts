#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/your-project.local/scripts
# $ ./update/10-prepare-composer.sh
CONFIG_M2_FILEPATH=`pwd`/config-m2.env
PROJECT_ROOT_PATH=`pwd`
# Check we are in the right directory
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

# Check that config file exists
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

# Load config variables
set -a; . `pwd`/config-m2.env

#
# Script-specific logic starts here
#

cd $MAGENTO2_ENV_WEBROOT || exit # Exit if 'cd' command fails

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
# NOT Cleaning frontend files...
#
"
#echo "
#$MAGENTO2_ENV_WEBROOT/var/view_preprocessed/css/frontend/*
#$MAGENTO2_ENV_WEBROOT/var/view_preprocessed/js/frontend/*
#$MAGENTO2_ENV_WEBROOT/var/view_preprocessed/source/frontend/*
#$MAGENTO2_ENV_WEBROOT/pub/static/frontend/*
#$MAGENTO2_ENV_WEBROOT/pub/static/_requirejs/frontend/*
#"
#rm -rf $MAGENTO2_ENV_WEBROOT/var/view_preprocessed/css/frontend/*
#rm -rf $MAGENTO2_ENV_WEBROOT/var/view_preprocessed/js/frontend/*
#rm -rf $MAGENTO2_ENV_WEBROOT/var/view_preprocessed/source/frontend/*
#rm -rf $MAGENTO2_ENV_WEBROOT/pub/static/frontend/*
#rm -rf $MAGENTO2_ENV_WEBROOT/pub/static/_requirejs/frontend/*

echo "
#
# Clearing all Redis caches in project...
# (do make sure the redis db numbers are correct)
#
"
#
# Database numbers are based on what is suggested in
# https://devdocs.magento.com/guides/v2.3/config-guide/redis/redis-pg-cache.html
#
# default
redis-cli -n 0 flushdb
# page_cache
redis-cli -n 1 flushdb
# session
redis-cli -n 2 flushdb
#echo "Skipping redis flushdb "

cd $MAGENTO2_ENV_WEBROOT || exit

#echo "
##
## $MAGENTO2_ENV_PHPCOMMAND -f $MAGENTO2_ENV_WEBROOT/bin/magento cache:clean
##
#"
#$MAGENTO2_ENV_PHPCOMMAND -f $MAGENTO2_ENV_WEBROOT/bin/magento cache:clean
echo "
#
# $MAGENTO2_ENV_PHPCOMMAND -f $MAGENTO2_ENV_WEBROOT/bin/magento cache:flush
#
"
$MAGENTO2_ENV_PHPCOMMAND -f $MAGENTO2_ENV_WEBROOT/bin/magento cache:flush || exit
echo "
#
# Enable all caches
#
# $MAGENTO2_ENV_PHPCOMMAND -f $MAGENTO2_ENV_WEBROOT/bin/magento cache:enable
#
"
$MAGENTO2_ENV_PHPCOMMAND -f $MAGENTO2_ENV_WEBROOT/bin/magento cache:enable || exit

#echo "
#
# $MAGENTO2_ENV_PHPCOMMAND -f $MAGENTO2_ENV_WEBROOT/bin/magento cache:disable full_page vertex
#
#"
#$MAGENTO2_ENV_PHPCOMMAND -f $MAGENTO2_ENV_WEBROOT/bin/magento cache:disable full_page vertex

#echo "
#
# $MAGENTO2_ENV_PHPCOMMAND /var/www/html/n98-magerun2.phar cache:list
#
#"
#$MAGENTO2_ENV_PHPCOMMAND /var/www/html/n98-magerun2.phar cache:list

echo "
#
# Restarting all PHP services
#
# @todo Change this so we only restart the project PHP service
#
"
#sudo service php7.0-fpm restart # Should we uninstall PHP7.0?
sudo service php7.1-fpm restart
sudo service php7.2-fpm restart
sudo service php7.3-fpm restart
sudo service php7.4-fpm restart
sudo service php8.0-fpm restart
sudo service php8.1-fpm restart
sudo service php8.2-fpm restart

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

#echo "
#
# Running $MAGENTO2_ENV_PHPCOMMAND /var/www/html/n98-magerun2.phar sys:setup:downgrade-versions
#
#"
#$MAGENTO2_ENV_PHPCOMMAND /var/www/html/n98-magerun2.phar sys:setup:downgrade-versions

echo "
#
# All done!
#
"
