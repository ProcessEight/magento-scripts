#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/english-braids.localhost.com/scripts
# $ ./update/10-prepare-composer.sh
CONFIG_M2_FILEPATH=`pwd`/config-m2.env
if [[ ! -f $CONFIG_M2_FILEPATH ]]; then
    echo "
#
# Could not detect config-m2.env.
# Create one first in $CONFIG_M2_FILEPATH
# Script cannot continue. Exiting now
#"
exit
fi
set -a; . `pwd`/config-m2.env

echo "
#
# 1. Prepare composer
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

echo "
#
# 2. Prepare database
#
"
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "create database $MAGENTO2_DB_NAME"
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "create user '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME' identified by '$MAGENTO2_DB_PASSWORD'"
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "grant all privileges on $MAGENTO2_DB_NAME.* to '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME'"

echo "
#
# 3. Prepare Magento 2
#
"

if [[ ! -d $MAGENTO2_ENV_WEBROOT ]]; then
    mkdir -p $MAGENTO2_ENV_WEBROOT

    echo "# Create a new, blank Magento 2 install"
    composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition $MAGENTO2_ENV_WEBROOT $MAGENTO2_ENV_VERSION
fi;
cd $MAGENTO2_ENV_WEBROOT

#echo "# Make sure we can execute the CLI tool"
#chmod u+x bin/magento
#echo "# Force correct permissions on files"
#sudo find var vendor pub/static pub/media app/etc -type f -exec chmod 775 {} \;
#echo "# Force correct permissions on directories"
#sudo find var vendor pub/static pub/media app/etc -type d -exec chmod 775 {} \;
#echo "# Force correct ownership on files"
#sudo find var vendor pub/static pub/media app/etc -type f -exec chown $MAGENTO2_ENV_CLIUSER:$MAGENTO2_ENV_WEBSERVERGROUP {} \;
#echo "# Force correct ownership on directories"
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

# Force correct ownership on files
#find var vendor pub/static pub/media app/etc -type f -exec chown $MAGENTO2_ENV_CLIUSER:$MAGENTO2_ENV_WEBSERVERGROUP {} \;
# Force correct ownership on directories
#find var vendor pub/static pub/media app/etc -type d -exec chown $MAGENTO2_ENV_CLIUSER:$MAGENTO2_ENV_WEBSERVERGROUP {} \;

# Code generation
if [[ $MAGENTO2_ENV_MULTITENANT == true ]];
then
    # For multisites running Magento 2.0.x only
    php -f bin/magento setup:di:compile-multi-tenant
else
    php -f bin/magento setup:di:compile
fi

# Static content generation
# There is an issue in Magento 2 where symlinks to static files produced in developer mode are not deleted during static content deployment
# So we need to manually clear out the pub/static folder (excluding the .htaccess file, if using Apache) to be sure
rm -rf pub/static/*
export DEPLOY_COMMAND="setup:static-content:deploy $MAGENTO2_LOCALE_CODE"
# Exclude configured themes
if [[ $MAGENTO2_STATICCONTENTDEPLOY_EXCLUDE == true ]]; then
    DEPLOY_COMMAND="$DEPLOY_COMMAND --exclude-theme $MAGENTO2_STATICCONTENTDEPLOY_EXCLUDEDTHEMES"
fi
php -f bin/magento $DEPLOY_COMMAND
# Generate static assets for Admin theme
php -f bin/magento setup:static-content:deploy en_US --theme Magento/backend

echo "
#
# 6. Run database changes
#
"
cd $MAGENTO2_ENV_WEBROOT

# Remove customer access to site (whitelisted IPs can still access frontend/backend)
php -f bin/magento maintenance:enable

# Don't remove the files we just generated
php -f bin/magento setup:upgrade --keep-generated
php -f bin/magento setup:db-schema:upgrade
php -f bin/magento setup:db-data:upgrade

# Allow access to site again
php -f bin/magento maintenance:disable

echo "
#
# 7. Set production settings
#
"
cd $MAGENTO2_ENV_WEBROOT

# Enable all caches
php -f bin/magento cache:enable

# We skip compilation here because we've already done in the previous step
php -f bin/magento deploy:mode:set production --skip-compilation

# Enable Magento 2 cron
if [[ $MAGENTO2_ENV_ENABLECRON ]]; then
    "* * * * * /usr/bin/php $MAGENTO2_ENV_WEBROOT/bin/magento cron:run | grep -v \"Ran jobs by schedule\" > $MAGENTO2_ENV_WEBROOT/var/log/magento.cron.log" >> /tmp/magento2-crontab
    "* * * * * /usr/bin/php $MAGENTO2_ENV_WEBROOT/update/cron.php > $MAGENTO2_ENV_WEBROOT/var/log/update.cron.log" /tmp/magento2-crontab
    "* * * * * /usr/bin/php $MAGENTO2_ENV_WEBROOT/bin/magento setup:cron:run > $MAGENTO2_ENV_WEBROOT/var/log/setup.cron.log" /tmp/magento2-crontab
    crontab /tmp/magento2-crontab
    php -f bin/magento setup:cron:run
fi
