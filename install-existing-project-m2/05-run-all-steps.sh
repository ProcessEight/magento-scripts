#!/usr/bin/env bash

#
# Setup an existing project in M2
#
# Assumptions
#
# Assumes that the project you are trying to setup DOES include the M2 source in its repo.
#
# Instructions
#
# - Run this script first to create a vanilla M2 instance
# - Then clone your repo and copy the files into the project
#

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

# Import config variables
set -a; . `pwd`/config-m2.env

if $MAGENTO2_DB_RESET; then

    echo "#"
    echo "# Prepare database"
    echo "#"

    echo "#"
    echo "# Running query: DROP DATABASE IF EXISTS $MAGENTO2_DB_NAME; CREATE DATABASE $MAGENTO2_DB_NAME"
    echo "#"
    mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "DROP DATABASE IF EXISTS $MAGENTO2_DB_NAME; CREATE DATABASE $MAGENTO2_DB_NAME"

    echo "#"
    echo "# Check if the user exists and if not, create a dummy user with a harmless privilege which we'll drop in the next step"
    echo "# This prevents MySQL from issuing an error if the user does not exist"
    echo "# Running query: GRANT USAGE ON *.* TO '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME' IDENTIFIED BY '$MAGENTO2_DB_PASSWORD'"
    echo "#"
    mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "GRANT USAGE ON *.* TO '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME' IDENTIFIED BY '$MAGENTO2_DB_PASSWORD'"

    echo "#"
    echo "# Running query: DROP USER '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME'"
    echo "#"
    mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "DROP USER '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME'"

    echo "#"
    echo "# Running query: CREATE USER '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME' IDENTIFIED BY '$MAGENTO2_DB_PASSWORD'"
    echo "#"
    mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "CREATE USER '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME' IDENTIFIED BY '$MAGENTO2_DB_PASSWORD'"

    echo "#"
    echo "# Running query: GRANT ALL PRIVILEGES ON $MAGENTO2_DB_NAME.* TO '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME'"
    echo "#"
    mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "GRANT ALL PRIVILEGES ON $MAGENTO2_DB_NAME.* TO '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME'"

    echo "#"
    echo "# Avoid the 'show_compatibility_56' error"
    echo "#"
    mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "SET global show_compatibility_56 = on"
fi

if $MAGENTO2_DB_IMPORT; then
    echo "#"
    echo "# Processing db backup"
    echo "#"

    echo "# Create a new db dump file in the M2 var directory"
    cd $MAGENTO2_ENV_WEBROOT/var/

    echo "# Concat the uncompressed db structure dump into the above file"
    pbzip2 -dc tredm2_magdev_structure.sql.bz2 >> db.sql || exit

    echo "# Concat the uncompressed db data dump into the above file"
    pbzip2 -dc tredm2_magdev_data.sql.bz2 >> db.sql || exit

    echo "# Switch back to M2 root (where the mage2-dbdump.sh script should be)"
    cd $MAGENTO2_ENV_WEBROOT

    echo "# Update definers"
    sed -i 's/`tredm2_magdev`@`172.16.%`/CURRENT_USER/g' $MAGENTO2_ENV_WEBROOT/var/db.sql

    echo "#"
    echo "# Restoring database using mage2-dbdump.sh"
    echo "#"

    ./mage2-dbdump.sh -r || exit

    # Update the URLs
    mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD $MAGENTO2_DB_NAME -e "UPDATE core_config_data SET value = 'http://$MAGENTO2_ENV_HOSTNAME/' WHERE value = 'https://m2.t-pass.co.uk/'"
    mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD $MAGENTO2_DB_NAME -e "UPDATE core_config_data SET value = 'http://$MAGENTO2_ENV_HOSTNAME/us/' WHERE value = 'https://m2.t-pass.co.uk/us/'"
    mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD $MAGENTO2_DB_NAME -e "UPDATE core_config_data SET value = 'http://$MAGENTO2_ENV_HOSTNAME/row/' WHERE value = 'https://m2.t-pass.co.uk/row/'"
    mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD $MAGENTO2_DB_NAME -e "UPDATE core_config_data SET value = 'http://$MAGENTO2_ENV_HOSTNAME/pl/' WHERE value = 'https://m2.t-pass.co.uk/pl/'"
    mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD $MAGENTO2_DB_NAME -e "UPDATE core_config_data SET value = 0 WHERE path = 'web/secure/use_in_frontend'"
    mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD $MAGENTO2_DB_NAME -e "UPDATE core_config_data SET value = 0 WHERE path = 'web/secure/use_in_adminhtml'"

fi

echo "
#
# 30. Prepare Magento 2
#
"

if [[ ! -f $MAGENTO2_ENV_WEBROOT/bin/magento ]]; then
    echo "
#
# The script has detected that the $MAGENTO2_ENV_WEBROOT/bin/magento file does not exist.
#
# This indicates that the installation of Magento 2 has failed.
#
# To continue, verify your Composer settings, remove the install directory ($MAGENTO2_ENV_WEBROOT) and try again.
#
# Script cannot continue. Exiting now.
#"
    exit
fi

cd $MAGENTO2_ENV_WEBROOT
chmod u+x bin/magento

if [[ $MAGENTO2_ENV_RESETPERMISSIONS == true ]]; then
echo "
#
# Updating file permissions...
#
"
    # Make sure we can execute the CLI tool
    chmod u+x bin/magento
    # Force correct permissions on files
    sudo find var vendor pub/static pub/media app/etc -type f -exec chmod u+w {} \;
    # Force correct permissions on directories
    sudo find var vendor pub/static pub/media app/etc -type d -exec chmod u+w {} \;
    # Force correct ownership on files
    sudo find var vendor pub/static pub/media app/etc -type f -exec chown $MAGENTO2_ENV_CLIUSER:$MAGENTO2_ENV_WEBSERVERGROUP {} \;
    # Force correct ownership on directories
    sudo find var vendor pub/static pub/media app/etc -type d -exec chown $MAGENTO2_ENV_CLIUSER:$MAGENTO2_ENV_WEBSERVERGROUP {} \;
    # Set the group-id bit to ensure that files and directories are generated with the right ownership
    sudo find var pub/static pub/media app/etc -type d -exec chmod g+s {} \;
fi

echo "
#
# 40. Install Magento 2
#
"
cd $MAGENTO2_ENV_WEBROOT

$MAGENTO2_ENV_COMPOSERCOMMAND install || exit

$MAGENTO2_ENV_PHPCOMMAND -f bin/magento setup:install --base-url=http://$MAGENTO2_ENV_HOSTNAME/ \
--db-host=$MAGENTO2_DB_HOSTNAME --db-name=$MAGENTO2_DB_NAME --db-user=$MAGENTO2_DB_USERNAME --db-password=$MAGENTO2_DB_PASSWORD \
--admin-firstname=$MAGENTO2_ADMIN_FIRSTNAME --admin-lastname=$MAGENTO2_ADMIN_LASTNAME --admin-email=$MAGENTO2_ADMIN_EMAIL \
--admin-user=$MAGENTO2_ADMIN_USERNAME --admin-password=$MAGENTO2_ADMIN_PASSWORD --language=$MAGENTO2_LOCALE_CODE \
--currency=$MAGENTO2_LOCALE_CURRENCY --timezone=$MAGENTO2_LOCALE_TIMEZONE --use-rewrites=$MAGENTO2_ENV_USEREWRITES --backend-frontname=$MAGENTO2_ADMIN_FRONTNAME --admin-use-security-key=$MAGENTO2_ENV_USESECURITYKEY \
--session-save=$MAGENTO2_ENV_SESSIONSAVE $MAGENTO2_INSTALLCOMMAND_CLEANUPDATABASE

echo "
#
# 60. Run database changes
#
"
cd $MAGENTO2_ENV_WEBROOT

# Remove customer access to site (whitelisted IPs can still access frontend/backend)
$MAGENTO2_ENV_PHPCOMMAND -f bin/magento maintenance:enable

# Apply database changes
$MAGENTO2_ENV_PHPCOMMAND -f bin/magento setup:upgrade

# Allow access to site again
$MAGENTO2_ENV_PHPCOMMAND -f bin/magento maintenance:disable

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
# Complete. Remember to run mage2tv/cache-clean
#
"
