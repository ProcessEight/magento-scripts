#!/usr/bin/env bash
#
# Create a brand new project in M2
#
# Run this script when creating a brand new Magento 2 project with no pre-existing codebase
# Run the install-existing-m2-project script when installing a Magento 2 project with a pre-existing codebase
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
set -a; . `pwd`/config-m2.env

#
# Script-specific logic starts here
#

echo "
#
# 10. Prepare composer
#
"

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

echo "
#
# 30. Prepare Magento 2
#
"

if [[ ! -d $MAGENTO2_ENV_WEBROOT ]]; then
    mkdir -p $MAGENTO2_ENV_WEBROOT

    echo "# Create a new, blank Magento 2 install"
    echo "# Running command: $MAGENTO2_ENV_COMPOSERCOMMAND create-project --repository-url=https://repo.magento.com/ magento/project-$MAGENTO2_ENV_EDITION-edition=$MAGENTO2_ENV_VERSION $MAGENTO2_ENV_WEBROOT"
    $MAGENTO2_ENV_COMPOSERCOMMAND create-project --repository-url=https://repo.magento.com/ magento/project-$MAGENTO2_ENV_EDITION-edition=$MAGENTO2_ENV_VERSION $MAGENTO2_ENV_WEBROOT || exit
else
    echo "
#
# The script has detected that the $MAGENTO2_ENV_WEBROOT directory already exists.
# The script will not overwrite existing files.
# To continue, move, rename or delete the $MAGENTO2_ENV_WEBROOT directory.
#
# Script cannot continue. Exiting now.
"
    exit
fi;

cd $MAGENTO2_ENV_WEBROOT || exit

if [[ ! -d $MAGENTO2_ENV_WEBROOT ]]; then
    echo "
#
# The script has detected that the $MAGENTO2_ENV_WEBROOT directory does not exist.
#
# To continue, verify permissions and ownership and try again.
#
# Script cannot continue. Exiting now.
#"
    exit
fi

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

cd $MAGENTO2_ENV_WEBROOT || exit

# Make sure we can execute the CLI tool
chmod u+x bin/magento

if [[ $MAGENTO2_ENV_RESETPERMISSIONS == true ]]; then
  echo "
#
# Updating file permissions...
#
"
  echo "# Set the group-id bit to ensure that files and directories are generated with the right ownership..."
  sudo find var generated pub/static pub/media app/etc -type f -exec chmod g+w {} + &&
    sudo find var generated pub/static pub/media app/etc -type d -exec chmod g+ws {} +
  echo "# Ensure a clean slate by flushing selected directories..."
  sudo rm -rf generated/code/ var/cache/ pub/static/* pub/media/*
fi

echo "
#
# 40. Install Magento $MAGENTO2_ENV_EDITION $MAGENTO2_ENV_VERSION
#
# Running command: $MAGENTO2_ENV_PHPCOMMAND -f bin/magento setup:install --base-url=http://$MAGENTO2_ENV_HOSTNAME/ --db-host=$MAGENTO2_DB_HOSTNAME --db-name=$MAGENTO2_DB_NAME --db-user=$MAGENTO2_DB_USERNAME --db-password=$MAGENTO2_DB_PASSWORD --admin-firstname=$MAGENTO2_ADMIN_FIRSTNAME --admin-lastname=$MAGENTO2_ADMIN_LASTNAME --admin-email=$MAGENTO2_ADMIN_EMAIL --admin-user=$MAGENTO2_ADMIN_USERNAME --admin-password=$MAGENTO2_ADMIN_PASSWORD --language=$MAGENTO2_LOCALE_CODE --currency=$MAGENTO2_LOCALE_CURRENCY --timezone=$MAGENTO2_LOCALE_TIMEZONE --use-rewrites=$MAGENTO2_ENV_USEREWRITES --backend-frontname=$MAGENTO2_ADMIN_FRONTNAME --admin-use-security-key=$MAGENTO2_ENV_USESECURITYKEY --session-save=$MAGENTO2_ENV_SESSIONSAVE $MAGENTO2_INSTALLCOMMAND_CLEANUPDATABASE $MAGENTO2_INSTALLCOMMAND_EXTRAARGUMENTS
#
"

$MAGENTO2_ENV_PHPCOMMAND -f bin/magento setup:install --base-url=http://$MAGENTO2_ENV_HOSTNAME/ \
--db-host=$MAGENTO2_DB_HOSTNAME --db-name=$MAGENTO2_DB_NAME --db-user=$MAGENTO2_DB_USERNAME --db-password=$MAGENTO2_DB_PASSWORD \
--admin-firstname=$MAGENTO2_ADMIN_FIRSTNAME --admin-lastname=$MAGENTO2_ADMIN_LASTNAME --admin-email=$MAGENTO2_ADMIN_EMAIL \
--admin-user=$MAGENTO2_ADMIN_USERNAME --admin-password=$MAGENTO2_ADMIN_PASSWORD --language=$MAGENTO2_LOCALE_CODE \
--currency=$MAGENTO2_LOCALE_CURRENCY --timezone=$MAGENTO2_LOCALE_TIMEZONE --use-rewrites=$MAGENTO2_ENV_USEREWRITES --backend-frontname=$MAGENTO2_ADMIN_FRONTNAME --admin-use-security-key=$MAGENTO2_ENV_USESECURITYKEY \
--session-save=$MAGENTO2_ENV_SESSIONSAVE $MAGENTO2_INSTALLCOMMAND_CLEANUPDATABASE $MAGENTO2_INSTALLCOMMAND_EXTRAARGUMENTS || exit

echo "
#
# 50. Setup Magento 2 backend
#
"
cd $MAGENTO2_ENV_WEBROOT || exit

echo "
#
# 55. Setup Magento 2 frontend
#
"
cd $MAGENTO2_ENV_WEBROOT || exit

echo "
#
# 60. Run database changes
#
"
cd $MAGENTO2_ENV_WEBROOT || exit

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
"

echo "
#
# Disabling 2FA module
#
"
$MAGENTO2_ENV_PHPCOMMAND -f bin/magento module:disable Magento_TwoFactorAuth Magento_AdminAdobeImsTwoFactorAuth

echo "
#
# Enabling all caches
#
"
$MAGENTO2_ENV_PHPCOMMAND -f bin/magento cache:enable

echo "
#
# NOT disabling full_page cache (use mage2tv/cache-clean instead)
#
"
#$MAGENTO2_ENV_PHPCOMMAND -f bin/magento cache:disable full_page
#$MAGENTO2_ENV_PHPCOMMAND -f bin/magento cache:flush full_page

echo "
#
# Set developer mode
#
"
$MAGENTO2_ENV_PHPCOMMAND -f bin/magento deploy:mode:set developer

if [[ $MAGENTO2_ENV_ENABLECRON == true ]]; then
    echo "
#
# Enabling Magento 2 cron
#
"
  $MAGENTO2_ENV_PHPCOMMAND -f bin/magento cron:install
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
