#!/usr/bin/env bash
set -a; . install.env

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
mysql -u root --password=password -e "create database $MAGENTO2_DB_NAME"
mysql -u root --password=password -e "create user '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME' identified by '$MAGENTO2_DB_PASSWORD'"
mysql -u root --password=password -e "grant all privileges on $MAGENTO2_DB_NAME.* to '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME'"

echo "
#
# 3. Prepare Magento 2
#
"
mkdir -p $MAGENTO2_ENV_WEBROOT
cd $MAGENTO2_ENV_WEBROOT
composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition $MAGENTO2_ENV_WEBROOT $MAGENTO2_ENV_VERSION
# Force correct permissions on files
find var vendor pub/static pub/media app/etc -type f -exec chmod u+w {} \;
# Force correct permissions on directories
find var vendor pub/static pub/media app/etc -type d -exec chmod u+w {} \;
chmod u+x bin/magento
chown $MAGENTO2_ENV_CLIUSER:$MAGENTO2_ENV_WEBSERVERGROUP -Rf .


echo "
#
# 4. Install Magento 2
#
"
bin/magento setup:install --base-url=http://$MAGENTO2_ENV_HOSTNAME/ \
--db-host=$MAGENTO2_DB_HOSTNAME --db-name=$MAGENTO2_DB_NAME --db-user=$MAGENTO2_DB_USERNAME --db-password=$MAGENTO2_DB_PASSWORD \
--admin-firstname=$MAGENTO2_ADMIN_FIRSTNAME --admin-lastname=$MAGENTO2_ADMIN_LASTNAME --admin-email=$MAGENTO2_ADMIN_EMAIL \
--admin-user=$MAGENTO2_ADMIN_USERNAME --admin-password=$MAGENTO2_ADMIN_PASSWORD --language=$MAGENTO2_LOCALE_CODE \
--currency=$MAGENTO2_LOCALE_CURRENCY --timezone=$MAGENTO2_LOCALE_TIMEZONE --use-rewrites=$MAGENTO2_CONFIG_REWRITES --backend-frontname=$MAGENTO2_ADMIN_FRONTNAME --admin-use-security-key=$MAGENTO2_CONFIG_SECURITYKEY \
--session-save=$MAGENTO2_ENV_SESSIONSAVE $MAGENTO2_INSTALLCOMMAND_CLEANUPDATABASE

echo "
#
# 5. Setup Magento 2
#
"
# Remove customer access to site (whitelisted IPs can still access frontend/backend)
bin/magento maintenance:enable

# Force correct ownership on files
find var vendor pub/static pub/media app/etc -type f -exec chown $MAGENTO2_ENV_CLIUSER:$MAGENTO2_ENV_WEBSERVERGROUP {} \;
# Force correct ownership on directories
find var vendor pub/static pub/media app/etc -type d -exec chown $MAGENTO2_ENV_CLIUSER:$MAGENTO2_ENV_WEBSERVERGROUP {} \;

# Upgrade database
bin/magento setup:upgrade
bin/magento setup:db-schema:upgrade
bin/magento setup:db-data:upgrade

# Code generation
if [[ $MAGENTO2_ENV_MULTITENANT ]];
then
    # For multisites running Magento 2.0.x only
    bin/magento setup:di:compile-multi-tenant
else
    bin/magento setup:di:compile
fi

# Static content generation
# There is an issue in Magento 2 where symlinks to static files produced in developer mode are not deleted during static content deployment
# So we need to manually clear out the pub/static folder (excluding the .htaccess file, if using Apache) to be sure
rm -rf pub/static/*
export DEPLOY_COMMAND="setup:static-content:deploy $MAGENTO2_LOCALE_CODE"
export DEPLOY_ADMINHTML_COMMAND="setup:static-content:deploy en_US --theme Magento/backend"
if [[ $MAGENTO2_STATICCONTENTDEPLOY_EXCLUDE ]];
then DEPLOY_COMMAND="setup:static-content:deploy $MAGENTO2_LOCALE_CODE $MAGENTO2_STATICCONTENTDEPLOY_EXCLUDE"
fi
bin/magento $DEPLOY_COMMAND
bin/magento $DEPLOY_ADMINHTML_COMMAND

bin/magento maintenance:disable




echo "
#
# 6. Set production settings
#
"
# Enable all caches
bin/magento cache:enable

# We skip compilation here because we've already done in the previous step
bin/magento deploy:mode:set production --skip-compilation

# Enable Magento 2 cron
#if [[ $MAGENTO2_ENV_ENABLECRON ]];
#then bin/magento setup:di:compile-multi-tenant
#fi

# Disable XDebug (if present)

# Enable OPCache