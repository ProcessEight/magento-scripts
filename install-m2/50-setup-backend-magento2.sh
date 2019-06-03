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
# 50. Setup Magento 2
#
"
cd $MAGENTO2_ENV_WEBROOT

#
# Code generation (PRODUCTION MODE ONLY)
#
#if [[ $MAGENTO2_ENV_MULTITENANT == true ]];
#then
    # For multisites running Magento 2.0.x only
#    $MAGENTO2_ENV_PHPCOMMAND -f bin/magento setup:di:compile-multi-tenant
#else
#    $MAGENTO2_ENV_PHPCOMMAND -f bin/magento setup:di:compile
#fi
# Now that we've generated all the possible classes that could exist,
# generate an optimised composer class map that supports faster autoloading
#$MAGENTO2_ENV_COMPOSERCOMMAND dump-autoload -o

# Static content generation
# There is an issue in Magento 2 where symlinks to static files produced in developer mode are not deleted during static content deployment
# So we need to manually clear out the pub/static folder (excluding the .htaccess file, if using Apache) to be sure
#rm -rf pub/static/*
#export DEPLOY_COMMAND="setup:static-content:deploy $MAGENTO2_LOCALE_CODE"
# Exclude configured themes
#if [[ $MAGENTO2_STATICCONTENTDEPLOY_EXCLUDE == true ]]; then
#    DEPLOY_COMMAND="$DEPLOY_COMMAND --exclude-theme $MAGENTO2_STATICCONTENTDEPLOY_EXCLUDEDTHEMES"
#fi
#$MAGENTO2_ENV_PHPCOMMAND -f bin/magento $DEPLOY_COMMAND
# Generate static assets for Admin theme
#$MAGENTO2_ENV_PHPCOMMAND -f bin/magento setup:static-content:deploy en_US --theme Magento/backend
