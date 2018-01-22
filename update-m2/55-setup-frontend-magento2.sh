#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/english-braids.localhost.com/scripts
# $ ./update/10-prepare-composer.sh
set -a; . `pwd`/config-m2.env
cd $MAGENTO2_ENV_WEBROOT

# Make sure we're running in developer mode
php -f bin/magento deploy:mode:set developer

# Static content generation
# There is an issue in Magento 2 where symlinks to static files produced in developer mode are not deleted during static content deployment
# So we need to manually clear out the pub/static folder (excluding the .htaccess file, if using Apache) to be sure
rm -rf pub/static/*
export DEPLOY_COMMAND="setup:static-content:deploy -f $MAGENTO2_LOCALE_CODE"

# Exclude configured themes
if [[ $MAGENTO2_STATICCONTENTDEPLOY_EXCLUDE == true ]]; then
    DEPLOY_COMMAND="$DEPLOY_COMMAND $MAGENTO2_STATICCONTENTDEPLOY_EXCLUDEDTHEMES"
fi

# Generate static assets for configured themes
php -f bin/magento $DEPLOY_COMMAND

# Generate static assets for Admin themes
php -f bin/magento setup:static-content:deploy en_US --theme Magento/backend --theme Purenet/backend

#cd $MAGENTO2_ENV_WEBROOT/vendor/snowdog/frontools

#echo "# Install yarn for gulp"
#curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
#echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
#sudo apt-get update && sudo apt-get install yarn
#yarn install

# Generate SASS
gulp styles --disableMaps --prod
