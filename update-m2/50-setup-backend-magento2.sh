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
# Now that we've generated all the possible classes that could exist,
# generate an optimised composer class map that supports faster autoloading
$MAGENTO2_ENV_COMPOSERCOMMAND dump-autoload -o

