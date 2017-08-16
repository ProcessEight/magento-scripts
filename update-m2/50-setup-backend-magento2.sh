#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/english-braids.localhost.com/scripts
# $ ./update/10-prepare-composer.sh
set -a; . `pwd`/config-m2.env
cd $MAGENTO2_ENV_WEBROOT

# Code generation

# Force clean old files first. Don't rely on Magento 2.
rm -rf var/generation/* var/di/*
if [[ $MAGENTO2_ENV_MULTITENANT == true ]];
# For multisites running Magento 2.0.x only
then
    php -f bin/magento setup:di:compile-multi-tenant
else
    php -f bin/magento setup:di:compile
fi
