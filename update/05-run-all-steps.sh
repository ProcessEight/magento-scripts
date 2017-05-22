#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/english-braids.localhost.com/scripts
# $ ./update/10-prepare-composer.sh
set -a; . `pwd`/config.env
cd $MAGENTO1_ENV_WEBROOT

echo "
#
# 10. Prepare composer
#
"
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

if [[ $MAGENTO2_DB_BACKUPFIRST == "true" ]];
then mysqldump -u root --password=password $MAGENTO2_DB_NAME > $MAGENTO2_DB_NAME.bak.sql
fi

# Install n98-magerun2
if [[ ! -f ./n98-magerun2.phar ]]; then
    wget https://files.magerun.net/n98-magerun2.phar && chmod +x ./n98-magerun2.phar
fi

# Composer parallel install plugin
composer global require hirak/prestissimo

# Install the project
# Reads the composer.lock file and installs/updates all dependencies to the specified version
composer install

echo "
#
# 30. Set permissions and ownership; Install frontend tools
#
"

# Make sure we can execute the CLI tool
chmod u+x bin/magento
# Force correct permissions on files
find var vendor pub/static pub/media app/etc -type f -exec chmod u+w {} \;
# Force correct permissions on directories
find var vendor pub/static pub/media app/etc -type d -exec chmod u+w {} \;
# Force correct ownership on files
find var vendor pub/static pub/media app/etc -type f -exec chown $MAGENTO2_ENV_CLIUSER:$MAGENTO2_ENV_WEBSERVERGROUP {} \;
# Force correct ownership on directories
find var vendor pub/static pub/media app/etc -type d -exec chown $MAGENTO2_ENV_CLIUSER:$MAGENTO2_ENV_WEBSERVERGROUP {} \;
# Set the sticky bit to ensure that files are generated with the right ownership
find var vendor pub/static pub/media app/etc -type d -exec chmod g+s {} \;

# This script assumes the tools needed to compile SASS to CSS are already installed
# If not however, they can be installed using the following commands
#curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
#echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
#sudo apt-get update && sudo apt-get install yarn
cd $MAGENTO2_ENV_WEBROOT/vendor/snowdog/frontools
yarn install

echo "
#
# 50. Code generation
#
"

cd $MAGENTO1_ENV_WEBROOT
# Code generation

# Force clean old files first. Don't rely on Magento 2.
rm -rf var/generation/* var/di/*
if [[ $MAGENTO2_ENV_MULTITENANT == "true" ]];
# For multisites running Magento 2.0.x only
then
    bin/magento setup:di:compile-multi-tenant
else
    bin/magento setup:di:compile
fi

echo "
#
# 55. Static content generation
#
"

# Static content generation
# There is an issue in Magento 2 where symlinks to static files produced in developer mode are not deleted during static content deployment
# So we need to manually clear out the pub/static folder (excluding the .htaccess file, if using Apache) to be sure
rm -rf pub/static/*
export DEPLOY_COMMAND="setup:static-content:deploy $MAGENTO2_LOCALE_CODE"
# Exclude configured themes
if [[ $MAGENTO2_STATICCONTENTDEPLOY_EXCLUDE == "true" ]]; then
    DEPLOY_COMMAND="$DEPLOY_COMMAND $MAGENTO2_STATICCONTENTDEPLOY_EXCLUDEDTHEMES"
fi
#echo $DEPLOY_COMMAND
bin/magento $DEPLOY_COMMAND

# Generate static assets for Admin theme
bin/magento setup:static-content:deploy en_US --theme Magento/backend

# Generate SASS
cd $MAGENTO2_ENV_WEBROOT/vendor/snowdog/frontools
gulp styles --disableMaps --prod


echo "
#
# 60. Update database schema and data
#
"
cd $MAGENTO1_ENV_WEBROOT

# Remove customer access to site (whitelisted IPs can still access frontend/backend)
bin/magento maintenance:enable

# Don't remove the files we just generated
bin/magento setup:upgrade --keep-generated
bin/magento setup:db-schema:upgrade
bin/magento setup:db-data:upgrade

# Allow access to site again
bin/magento maintenance:disable

echo "
#
# 70. Set production settings
#
"

# Enable all caches
bin/magento cache:enable

# We skip compilation here because we've already done in the previous step
bin/magento deploy:mode:set production --skip-compilation

# Enable Magento 2 cron
if [[ $MAGENTO2_ENV_ENABLECRON ]];
    then
        "* * * * * /usr/bin/php $MAGENTO2_ENV_WEBROOT/bin/magento cron:run | grep -v "Ran jobs by schedule" >> $MAGENTO2_ENV_WEBROOT/var/log/magento.cron.log" >> /tmp/magento2-crontab
        "* * * * * /usr/bin/php $MAGENTO2_ENV_WEBROOT/update/cron.php >> $MAGENTO2_ENV_WEBROOT/var/log/update.cron.log" /tmp/magento2-crontab
        "* * * * * /usr/bin/php $MAGENTO2_ENV_WEBROOT/bin/magento setup:cron:run >> $MAGENTO2_ENV_WEBROOT/var/log/setup.cron.log" /tmp/magento2-crontab
        crontab /tmp/magento2-crontab
        bin/magento setup:cron:run
fi
