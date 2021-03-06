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

echo "
#
# Install Magento 2
#
"
cd $MAGENTO2_ENV_WEBROOT

$MAGENTO2_ENV_PHPCOMMAND -f bin/magento setup:install -vvv --base-url=http://$MAGENTO2_ENV_HOSTNAME/ \
--db-host=$MAGENTO2_DB_HOSTNAME --db-name=$MAGENTO2_DB_NAME --db-user=$MAGENTO2_DB_USERNAME --db-password=$MAGENTO2_DB_PASSWORD \
--admin-firstname=$MAGENTO2_ADMIN_FIRSTNAME --admin-lastname=$MAGENTO2_ADMIN_LASTNAME --admin-email=$MAGENTO2_ADMIN_EMAIL \
--admin-user=$MAGENTO2_ADMIN_USERNAME --admin-password=$MAGENTO2_ADMIN_PASSWORD --language=$MAGENTO2_LOCALE_CODE \
--currency=$MAGENTO2_LOCALE_CURRENCY --timezone=$MAGENTO2_LOCALE_TIMEZONE --use-rewrites=$MAGENTO2_ENV_USEREWRITES --backend-frontname=$MAGENTO2_ADMIN_FRONTNAME --admin-use-security-key=$MAGENTO2_ENV_USESECURITYKEY \
--session-save=$MAGENTO2_ENV_SESSIONSAVE $MAGENTO2_INSTALLCOMMAND_CLEANUPDATABASE

echo "
#
# Run database changes
#
"

# Remove customer access to site (whitelisted IPs can still access frontend/backend)
$MAGENTO2_ENV_PHPCOMMAND -f bin/magento maintenance:enable

$MAGENTO2_ENV_PHPCOMMAND -f bin/magento setup:upgrade
#$MAGENTO2_ENV_PHPCOMMAND -f bin/magento setup:db-schema:upgrade
#$MAGENTO2_ENV_PHPCOMMAND -f bin/magento setup:db-data:upgrade

# Allow access to site again
$MAGENTO2_ENV_PHPCOMMAND -f bin/magento maintenance:disable

echo "
#
# Set developer mode
#
"

echo "# Enable all caches "
$MAGENTO2_ENV_PHPCOMMAND -f bin/magento cache:enable

echo "# Make sure we're running in developer mode "
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
