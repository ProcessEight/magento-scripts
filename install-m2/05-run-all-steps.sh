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

echo "
#
# 10. Prepare composer
#
"

COMPOSER_CMD=$(which composer)
if [[ "" == "$COMPOSER_CMD" ]]; then
    echo "
#
# The script has detected that Composer is not installed.
# The script does not have permissions to install it.
# To continue, install Composer first
#
# Script cannot continue. Exiting now.
#"
    exit
fi

if [[ ! -d ~/.composer/ ]]; then
    echo "
#
# Adding repo.magento.com access keys to ~/.composer/auth.json...
#
"
    mkdir -p ~/.composer/

    echo "{
       \"http-basic\": {
          \"repo.magento.com\": {
             \"username\": \"$MAGENTO2_PUBLIC_KEY\",
             \"password\": \"$MAGENTO2_PRIVATE_KEY\"
          }
       }
    }" > ~/.composer/auth.json
fi

echo "
#
# 2. Prepare database
#
"
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "DROP DATABASE IF EXISTS $MAGENTO2_DB_NAME; CREATE DATABASE $MAGENTO2_DB_NAME"

# Check if the user exists and if not, create a dummy user with a harmless privilege which we'll drop in the next step
# This prevents MySQL from issuing an error if the user does not exist
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "GRANT USAGE ON *.* TO '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME' IDENTIFIED BY '$MAGENTO2_DB_PASSWORD'"
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "DROP USER '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME'"
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "CREATE USER '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME' IDENTIFIED BY '$MAGENTO2_DB_PASSWORD'"
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "GRANT ALL PRIVILEGES ON $MAGENTO2_DB_NAME.* TO '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME'"

echo "
#
# 3. Prepare Magento 2
#
"

if [[ ! -d $MAGENTO2_ENV_WEBROOT ]]; then
    mkdir -p $MAGENTO2_ENV_WEBROOT

    echo "# Create a new, blank Magento 2 install"
    composer create-project --repository-url=https://repo.magento.com/ magento/project-$MAGENTO2_ENV_EDITION-edition $MAGENTO2_ENV_WEBROOT $MAGENTO2_ENV_VERSION
else
    echo "
#
# The script has detected that the $MAGENTO2_ENV_WEBROOT directory already exists.
# The script will not overwrite existing files.
# To continue, move, rename or delete the $MAGENTO2_ENV_WEBROOT directory.
#
# Script cannot continue. Exiting now.
#"
#    exit
fi;

cd $MAGENTO2_ENV_WEBROOT

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

chmod u+x bin/magento
#echo "# Force correct permissions on files"
#sudo find var vendor pub/static pub/media app/etc -type f -exec chmod 775 {} \;
#echo "# Force correct permissions on directories"
#sudo find var vendor pub/static pub/media app/etc -type d -exec chmod 775 {} \;
#echo "# Forcing correct ownership on files..."
#sudo find var vendor pub/static pub/media app/etc -type f -exec chown $MAGENTO2_ENV_CLIUSER:$MAGENTO2_ENV_WEBSERVERGROUP {} \;
#echo "# Forcing correct ownership on directories..."
#sudo find var vendor pub/static pub/media app/etc -type d -exec chown $MAGENTO2_ENV_CLIUSER:$MAGENTO2_ENV_WEBSERVERGROUP {} \;
#echo "# Set the sticky bit to ensure that files are generated with the right ownership"
#sudo find var vendor pub/static pub/media app/etc -type d -exec chmod g+s {} \;
echo "
#
# 4. Install Magento 2
#
"
cd $MAGENTO2_ENV_WEBROOT

php -f bin/magento setup:install --base-url=http://$MAGENTO2_ENV_HOSTNAME/ \
--db-host=$MAGENTO2_DB_HOSTNAME --db-name=$MAGENTO2_DB_NAME --db-user=$MAGENTO2_DB_USERNAME --db-password=$MAGENTO2_DB_PASSWORD \
--admin-firstname=$MAGENTO2_ADMIN_FIRSTNAME --admin-lastname=$MAGENTO2_ADMIN_LASTNAME --admin-email=$MAGENTO2_ADMIN_EMAIL \
--admin-user=$MAGENTO2_ADMIN_USERNAME --admin-password=$MAGENTO2_ADMIN_PASSWORD --language=$MAGENTO2_LOCALE_CODE \
--currency=$MAGENTO2_LOCALE_CURRENCY --timezone=$MAGENTO2_LOCALE_TIMEZONE --use-rewrites=$MAGENTO2_ENV_USEREWRITES --backend-frontname=$MAGENTO2_ADMIN_FRONTNAME --admin-use-security-key=$MAGENTO2_ENV_USESECURITYKEY \
--session-save=$MAGENTO2_ENV_SESSIONSAVE $MAGENTO2_INSTALLCOMMAND_CLEANUPDATABASE

echo "
#
# 5. Setup Magento 2
#
"
cd $MAGENTO2_ENV_WEBROOT

#
# Code generation (PRODUCTION MODE ONLY)
#
#if [[ $MAGENTO2_ENV_MULTITENANT == true ]];
#then
    # For multisites running Magento 2.0.x only
#    php -f bin/magento setup:di:compile-multi-tenant
#else
#    php -f bin/magento setup:di:compile
#fi
# Now that we've generated all the possible classes that could exist,
# generate an optimised composer class map that supports faster autoloading
#composer dump-autoload -o

# Static content generation
# There is an issue in Magento 2 where symlinks to static files produced in developer mode are not deleted during static content deployment
# So we need to manually clear out the pub/static folder (excluding the .htaccess file, if using Apache) to be sure
#rm -rf pub/static/*
#export DEPLOY_COMMAND="setup:static-content:deploy $MAGENTO2_LOCALE_CODE"
# Exclude configured themes
#if [[ $MAGENTO2_STATICCONTENTDEPLOY_EXCLUDE == true ]]; then
#    DEPLOY_COMMAND="$DEPLOY_COMMAND --exclude-theme $MAGENTO2_STATICCONTENTDEPLOY_EXCLUDEDTHEMES"
#fi
#php -f bin/magento $DEPLOY_COMMAND
# Generate static assets for Admin theme
#php -f bin/magento setup:static-content:deploy en_US --theme Magento/backend

echo "
#
# 6. Run database changes
#
"
cd $MAGENTO2_ENV_WEBROOT

# Remove customer access to site (whitelisted IPs can still access frontend/backend)
php -f bin/magento maintenance:enable

php -f bin/magento setup:upgrade

# Allow access to site again
php -f bin/magento maintenance:disable

echo "
#
# 7. Enable developer mode
#
"
cd $MAGENTO2_ENV_WEBROOT

# Enable all caches
php -f bin/magento cache:enable

# Make sure we're running in developer mode
php -f bin/magento deploy:mode:set developer

# Enable Magento 2 cron
if [[ $MAGENTO2_ENV_ENABLECRON ]]; then
    echo "* * * * * /usr/bin/php $MAGENTO2_ENV_WEBROOT/bin/magento cron:run | grep -v \"Ran jobs by schedule\" > $MAGENTO2_ENV_WEBROOT/var/log/magento.cron.log" >> /tmp/magento2-crontab
    echo "* * * * * /usr/bin/php $MAGENTO2_ENV_WEBROOT/update/cron.php > $MAGENTO2_ENV_WEBROOT/var/log/update.cron.log" /tmp/magento2-crontab
    echo "* * * * * /usr/bin/php $MAGENTO2_ENV_WEBROOT/bin/magento setup:cron:run > $MAGENTO2_ENV_WEBROOT/var/log/setup.cron.log" /tmp/magento2-crontab
    crontab /tmp/magento2-crontab
    php -f bin/magento setup:cron:run
fi
