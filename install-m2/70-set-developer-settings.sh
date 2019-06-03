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
# 70. Apply environment-specific settings
#
"

echo "
#
# Enabling all caches
#
"
$MAGENTO2_ENV_PHPCOMMAND -f bin/magento cache:enable

echo "
#
# Disabling full_page cache
#
"
$MAGENTO2_ENV_PHPCOMMAND -f bin/magento cache:disable full_page
$MAGENTO2_ENV_PHPCOMMAND -f bin/magento cache:flush full_page

echo "
#
# Enabling developer mode
#
"
$MAGENTO2_ENV_PHPCOMMAND -f bin/magento deploy:mode:set developer

if [[ $MAGENTO2_ENV_ENABLECRON == true ]]; then
    echo "
#
# Enabling Magento 2 cron
#
"
    echo "* * * * * /usr/bin/$MAGENTO2_ENV_PHPCOMMAND $MAGENTO2_ENV_WEBROOT/bin/magento cron:run | grep -v \"Ran jobs by schedule\" > $MAGENTO2_ENV_WEBROOT/var/log/magento.cron.log" >> /tmp/magento2-crontab
    echo "* * * * * /usr/bin/$MAGENTO2_ENV_PHPCOMMAND $MAGENTO2_ENV_WEBROOT/update/cron.php > $MAGENTO2_ENV_WEBROOT/var/log/update.cron.log" /tmp/magento2-crontab
    echo "* * * * * /usr/bin/$MAGENTO2_ENV_PHPCOMMAND $MAGENTO2_ENV_WEBROOT/bin/magento setup:cron:run > $MAGENTO2_ENV_WEBROOT/var/log/setup.cron.log" /tmp/magento2-crontab
    crontab /tmp/magento2-crontab
    $MAGENTO2_ENV_PHPCOMMAND -f bin/magento setup:cron:run
fi

echo "
#
# Now that we've generated all the possible classes that could exist,
# generate an optimised composer class map that supports faster autoloading
#
"
$MAGENTO2_ENV_COMPOSERCOMMAND dump-autoload -o

echo "
#
# Complete. Remember to run mage2tv/cache-clean
#
"
