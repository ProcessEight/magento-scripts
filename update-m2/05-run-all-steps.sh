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
# Create one first in $PROJECT_ROOT_PATH/config-m2.env and make sure you are running this script from the scripts directory.
#
# Script cannot continue. Exiting now.
#"
exit
fi
set -a; . `pwd`/config-m2.env

cd $MAGENTO2_ENV_WEBROOT

echo "
#
# 10. Prepare composer
#
"

COMPOSER_CMD=$(which composer)
if [[ "" == "$COMPOSER_CMD" ]]; then
    echo "
#
# Could not detect Composer.
# Make sure composer is installed and then try again.
#
# Script cannot continue. Exiting now.
#
"
exit
fi

if [[ ! -f ~/.composer/auth.json ]]; then
    echo "
#
# The script has detected that ~/.composer/auth.json does not exist.
# The script will not create it.
# To continue, create it first using:
# $ composer config -g http-basic.repo.magento.com <public_key> <private_key>
#
# Script cannot continue. Exiting now.
#"
    exit
fi

echo "
#
# 20. Prepare database
#
"

if [[ $MAGENTO2_DB_BACKUPFIRST == true ]]; then
    mysqldump $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD $MAGENTO2_DB_NAME > $MAGENTO2_DB_NAME.bak.sql
fi

if [[ $MAGENTO2_DB_RESET == true ]]; then
    echo "# Remove existing database"
#    echo "# DROP DATABASE IF EXISTS $MAGENTO2_DB_NAME"
    mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "DROP DATABASE IF EXISTS $MAGENTO2_DB_NAME"

    echo "# Check if the user exists and if not, create a dummy user with a harmless privilege which we'll drop in the next step"
    echo "# This prevents MySQL from issuing an error if the user does not exist"
#    echo "# GRANT USAGE ON *.* TO '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME' IDENTIFIED BY '$MAGENTO2_DB_PASSWORD'"
#    echo "# DROP USER '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME'"
    mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "GRANT USAGE ON *.* TO '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME' IDENTIFIED BY '$MAGENTO2_DB_PASSWORD'"
    mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "DROP USER '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME'"

    echo "# Create new database and user"
#    echo "# CREATE DATABASE $MAGENTO2_DB_NAME"
#    echo "# CREATE USER '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME' IDENTIFIED BY '$MAGENTO2_DB_PASSWORD'"
#    echo "# GRANT ALL PRIVILEGES ON $MAGENTO2_DB_NAME.* TO '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME'"
    mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "CREATE DATABASE $MAGENTO2_DB_NAME"
    mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "CREATE USER '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME' IDENTIFIED BY '$MAGENTO2_DB_PASSWORD'"
    mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "GRANT ALL PRIVILEGES ON $MAGENTO2_DB_NAME.* TO '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME'"
fi

if [[ $MAGENTO2_DB_IMPORT == true ]]; then
    echo "# Importing $MAGENTO2_DB_DUMPNAME into $MAGENTO2_DB_NAME"
    pv $MAGENTO2_DB_DUMPNAME | mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD $MAGENTO2_DB_NAME
fi

echo "
#
# 30. Prepare Magento 2
#
"

cd $MAGENTO2_ENV_WEBROOT

# Install the project
# Reads the composer.lock file and installs/updates all dependencies to the specified version
$MAGENTO2_ENV_COMPOSERCOMMAND install

if [[ $MAGENTO2_ENV_RESETPERMISSIONS == true ]]; then

echo "
#
# Updating file permissions...
#
"

    # Make sure we can execute the CLI tool
    chmod u+x bin/magento
    echo "# Set the group-id bit to ensure that files and directories are generated with the right ownership..."
    sudo find var generated pub/static pub/media app/etc -type f -exec chmod g+w {} + &&
    sudo find var generated pub/static pub/media app/etc -type d -exec chmod g+ws {} +
    echo "# Ensure a clean slate by flushing selected directories..."
    sudo rm -rf generated/code/ var/cache/ pub/static/* pub/media/*
fi

# Ensure the application is installed correctly (especially if we re-imported the database)
$MAGENTO2_ENV_PHPCOMMAND -f bin/magento setup:install --base-url=http://$MAGENTO2_ENV_HOSTNAME/ \
--db-host=$MAGENTO2_DB_HOSTNAME --db-name=$MAGENTO2_DB_NAME --db-user=$MAGENTO2_DB_USERNAME --db-password=$MAGENTO2_DB_PASSWORD \
--admin-firstname=$MAGENTO2_ADMIN_FIRSTNAME --admin-lastname=$MAGENTO2_ADMIN_LASTNAME --admin-email=$MAGENTO2_ADMIN_EMAIL \
--admin-user=$MAGENTO2_ADMIN_USERNAME --admin-password=$MAGENTO2_ADMIN_PASSWORD --language=$MAGENTO2_LOCALE_CODE \
--currency=$MAGENTO2_LOCALE_CURRENCY --timezone=$MAGENTO2_LOCALE_TIMEZONE --use-rewrites=$MAGENTO2_ENV_USEREWRITES --backend-frontname=$MAGENTO2_ADMIN_FRONTNAME --admin-use-security-key=$MAGENTO2_ENV_USESECURITYKEY \
--session-save=$MAGENTO2_ENV_SESSIONSAVE $MAGENTO2_INSTALLCOMMAND_CLEANUPDATABASE

# Force clean old files first. Don't rely on Magento 2.
rm -rf var/generation/* var/di/* generated/*

# Now that we've generated all the possible classes that could exist,
# generate an optimised composer class map that supports faster autoloading
# (production mode only)
#$MAGENTO2_ENV_COMPOSERCOMMAND dump-autoload -o

# Make sure we're running in developer mode
$MAGENTO2_ENV_PHPCOMMAND -f bin/magento deploy:mode:set developer

# Static content generation
# There is an issue in Magento 2 where symlinks to static files produced in developer mode are not deleted during static content deployment
# So we need to manually clear out the pub/static folder (excluding the .htaccess file, if using Apache) to be sure
rm -rf pub/static/*

echo "
#
# 40. Update Magento to $MAGENTO2_ENV_EDITION $MAGENTO2_ENV_VERSION
#
"

# Update to the specified version
$MAGENTO2_ENV_COMPOSERCOMMAND require magento/product-$MAGENTO2_ENV_EDITION-edition $MAGENTO2_ENV_VERSION --no-update
$MAGENTO2_ENV_COMPOSERCOMMAND update

rm -rf $MAGENTO2_ENV_WEBROOT/var/cache/* $MAGENTO2_ENV_WEBROOT/var/page_cache/* $MAGENTO2_ENV_WEBROOT/var/generation/* $MAGENTO2_ENV_WEBROOT/generated/*

echo "
#
# 60. Update database schema and data
#
"

# Disable customer access to site (whitelisted IPs can still access frontend/backend)
$MAGENTO2_ENV_PHPCOMMAND -f bin/magento maintenance:enable

# Upgrade the database, run setup scripts of all modules
$MAGENTO2_ENV_PHPCOMMAND -f bin/magento setup:upgrade

# Allow access to site again
$MAGENTO2_ENV_PHPCOMMAND -f bin/magento maintenance:disable

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

# Enable Magento 2 cron
if [[ $MAGENTO2_ENV_ENABLECRON ]]; then
    touch $MAGENTO2_ENV_WEBROOT/var/log/magento.cron.log
    touch $MAGENTO2_ENV_WEBROOT/var/log/update.cron.log
    touch $MAGENTO2_ENV_WEBROOT/var/log/setup.cron.log
    echo "* * * * * $MAGENTO2_ENV_PHPCOMMAND $MAGENTO2_ENV_WEBROOT/bin/magento cron:run | grep -v \"Ran jobs by schedule\" >> $MAGENTO2_ENV_WEBROOT/var/log/magento.cron.log" > /tmp/magento2-crontab
    echo "* * * * * $MAGENTO2_ENV_PHPCOMMAND $MAGENTO2_ENV_WEBROOT/update/cron.php >> $MAGENTO2_ENV_WEBROOT/var/log/update.cron.log" >> /tmp/magento2-crontab
    echo "* * * * * $MAGENTO2_ENV_PHPCOMMAND $MAGENTO2_ENV_WEBROOT/bin/magento setup:cron:run >> $MAGENTO2_ENV_WEBROOT/var/log/setup.cron.log" >> /tmp/magento2-crontab
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
