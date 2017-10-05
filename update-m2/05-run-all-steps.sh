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
cd $MAGENTO2_ENV_WEBROOT

COMPOSER_CMD=$(which composer)
if [[ "" == "$COMPOSER_CMD" ]]
then
    wget https://raw.githubusercontent.com/composer/getcomposer.org/a68fc08d2de42237ae80d77e8dd44488d268e13d/web/installer -O - -q | php -- --quiet --filename=composer
fi

mkdir -p ~/.composer/

echo "{
   \"http-basic\": {
      \"repo.magento.com\": {
         \"username\": \"$MAGENTO2_PUBLIC_KEY\",
         \"password\": \"$MAGENTO2_PRIVATE_KEY\"
      }
   }
}" > ~/.composer/auth.json


echo "
#
# 20. Prepare database
#
"
cd $MAGENTO2_ENV_WEBROOT

if [[ $MAGENTO2_DB_BACKUPFIRST == true ]]; then
    mysqldump $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD $MAGENTO2_DB_NAME > $MAGENTO2_DB_NAME.bak.sql
fi

if [[ $MAGENTO2_DB_IMPORT == true ]]; then
echo "# Remove existing database"
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "DROP DATABASE IF EXISTS $MAGENTO2_DB_NAME"
echo "# Check if the user exists and if not, create a dummy user with a harmless privilege which we'll drop in the next step"
echo "# This prevents MySQL from issuing and error if the user does not exist"
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "GRANT USAGE ON *.* TO '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME' IDENTIFIED BY '$MAGENTO2_DB_PASSWORD'"
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "DROP USER '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME'"
echo "# Create new database and user"
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "CREATE DATABASE $MAGENTO2_DB_NAME"
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "CREATE USER '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME' IDENTIFIED BY '$MAGENTO2_DB_PASSWORD'"
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "GRANT ALL PRIVILEGES ON $MAGENTO2_DB_NAME.* TO '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME'"
echo "# Importing database dump"
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD $MAGENTO2_DB_NAME < $MAGENTO2_DB_DUMPNAME
fi

echo "
#
# 30. Set permissions and ownership
#
"
cd $MAGENTO2_ENV_WEBROOT

## Make sure we can execute the CLI tool
#chmod u+x bin/magento
## Force correct permissions on files
#sudo find var vendor pub/static pub/media app/etc -type f -exec chmod u+w {} \;
## Force correct permissions on directories
#sudo find var vendor pub/static pub/media app/etc -type d -exec chmod u+w {} \;
## Force correct ownership on files
#sudo find var vendor pub/static pub/media app/etc -type f -exec chown $MAGENTO2_ENV_CLIUSER:$MAGENTO2_ENV_WEBSERVERGROUP {} \;
## Force correct ownership on directories
#sudo find var vendor pub/static pub/media app/etc -type d -exec chown $MAGENTO2_ENV_CLIUSER:$MAGENTO2_ENV_WEBSERVERGROUP {} \;
## Set the group-id bit to ensure that files and directories are generated with the right ownership
#sudo find var pub/static pub/media app/etc -type d -exec chmod g+s {} \;

echo "
#
# 40. Update Magento 2
#
"
cd $MAGENTO2_ENV_WEBROOT

# Install the project
# Reads the composer.lock file and installs/updates all dependencies to the specified version
composer install

# Make sure we can execute the CLI tool
#chmod u+x bin/magento
#php -f bin/magento module:enable --all

# Ensure the application is installed (especially if we re-imported the database)
php -f bin/magento setup:install --base-url=http://$MAGENTO2_ENV_HOSTNAME/ \
--db-host=$MAGENTO2_DB_HOSTNAME --db-name=$MAGENTO2_DB_NAME --db-user=$MAGENTO2_DB_USERNAME --db-password=$MAGENTO2_DB_PASSWORD \
--admin-firstname=$MAGENTO2_ADMIN_FIRSTNAME --admin-lastname=$MAGENTO2_ADMIN_LASTNAME --admin-email=$MAGENTO2_ADMIN_EMAIL \
--admin-user=$MAGENTO2_ADMIN_USERNAME --admin-password=$MAGENTO2_ADMIN_PASSWORD --language=$MAGENTO2_LOCALE_CODE \
--currency=$MAGENTO2_LOCALE_CURRENCY --timezone=$MAGENTO2_LOCALE_TIMEZONE --use-rewrites=$MAGENTO2_ENV_USEREWRITES --backend-frontname=$MAGENTO2_ADMIN_FRONTNAME --admin-use-security-key=$MAGENTO2_ENV_USESECURITYKEY \
--session-save=$MAGENTO2_ENV_SESSIONSAVE $MAGENTO2_INSTALLCOMMAND_CLEANUPDATABASE

echo "
#
# 50. Code generation
#
"
cd $MAGENTO2_ENV_WEBROOT
# Code generation

# Force clean old files first. Don't rely on Magento 2.
rm -rf var/generation/* var/di/*
#if [[ $MAGENTO2_ENV_MULTITENANT == true ]];
## For multisites running Magento 2.0.x only
#then
#    php -f bin/magento setup:di:compile-multi-tenant
#else
#    php -f bin/magento setup:di:compile
#fi

echo "
#
# 55. Static content generation
#
"
cd $MAGENTO2_ENV_WEBROOT

# Make sure we're running in developer mode
php -f bin/magento deploy:mode:set developer

# Static content generation
# There is an issue in Magento 2 where symlinks to static files produced in developer mode are not deleted during static content deployment
# So we need to manually clear out the pub/static folder (excluding the .htaccess file, if using Apache) to be sure
rm -rf pub/static/*
#export DEPLOY_COMMAND="setup:static-content:deploy $MAGENTO2_LOCALE_CODE"

# Exclude configured themes
#if [[ $MAGENTO2_STATICCONTENTDEPLOY_EXCLUDE == true ]]; then
#    DEPLOY_COMMAND="$DEPLOY_COMMAND $MAGENTO2_STATICCONTENTDEPLOY_EXCLUDEDTHEMES"
#fi

# Generate static assets for configured themes
#php -f bin/magento $DEPLOY_COMMAND

# Generate static assets for Admin themes
#php -f bin/magento setup:static-content:deploy en_US --theme Magento/backend --theme Purenet/backend

#cd $MAGENTO2_ENV_WEBROOT/vendor/snowdog/frontools

#echo "# Install yarn for gulp"
#curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
#echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
#sudo apt-get update && sudo apt-get install yarn
#yarn install

# Generate SASS
#gulp styles --disableMaps --prod

echo "
#
# 60. Update database schema and data
#
"
cd $MAGENTO2_ENV_WEBROOT

# Disable customer access to site (whitelisted IPs can still access frontend/backend)
php -f bin/magento maintenance:enable

# Don't remove the files we just generated
php -f bin/magento setup:upgrade --keep-generated
php -f bin/magento setup:db-schema:upgrade
php -f bin/magento setup:db-data:upgrade

# Allow access to site again
php -f bin/magento maintenance:disable

# Install n98-magerun2
if [[ ! -f ./n98-magerun2.phar ]]; then
    wget https://files.magerun.net/n98-magerun2.phar && chmod +x ./n98-magerun2.phar
fi

echo "
#
# 70. Set production settings
#
"

cd $MAGENTO2_ENV_WEBROOT

# Enable all caches
php -f bin/magento cache:enable

# We skip compilation here because we've already done in the previous step
#php -f bin/magento deploy:mode:set production --skip-compilation

# Enable Magento 2 cron
if [[ $MAGENTO2_ENV_ENABLECRON ]]; then
    touch $MAGENTO2_ENV_WEBROOT/var/log/magento.cron.log
    touch $MAGENTO2_ENV_WEBROOT/var/log/update.cron.log
    touch $MAGENTO2_ENV_WEBROOT/var/log/setup.cron.log
    "* * * * * /usr/bin/php $MAGENTO2_ENV_WEBROOT/bin/magento cron:run | grep -v \"Ran jobs by schedule\" >> $MAGENTO2_ENV_WEBROOT/var/log/magento.cron.log" >> /tmp/magento2-crontab
    "* * * * * /usr/bin/php $MAGENTO2_ENV_WEBROOT/update/cron.php >> $MAGENTO2_ENV_WEBROOT/var/log/update.cron.log" /tmp/magento2-crontab
    "* * * * * /usr/bin/php $MAGENTO2_ENV_WEBROOT/bin/magento setup:cron:run >> $MAGENTO2_ENV_WEBROOT/var/log/setup.cron.log" /tmp/magento2-crontab
    crontab /tmp/magento2-crontab
    php -f bin/magento setup:cron:run
fi
