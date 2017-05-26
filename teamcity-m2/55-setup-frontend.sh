#!/usr/bin/env bash

#
# Team City build step configuration
#
# Runner Type:          Command Line
# Step name:            55: Setup Frontend
# Execute Step:         If all previous steps finished successfully (zero exit code)
# Working directory:    htdocs
# Run:                  Custom script
# Custom script:        See below
#

# Static content generation
# There is an issue in Magento 2 where symlinks to static files produced in developer mode are not deleted during static content deployment
# So we need to manually clear out the pub/static folder (excluding the .htaccess file, if using Apache) to be sure
rm -rf pub/static/*

export DEPLOY_COMMAND="setup:static-content:deploy %env.MAGENTO2_LOCALE_CODE%"
# Exclude configured themes
if [[ %env.MAGENTO2_STATICCONTENTDEPLOY_EXCLUDE% == true ]]; then
    DEPLOY_COMMAND="$DEPLOY_COMMAND %env.MAGENTO2_STATICCONTENTDEPLOY_EXCLUDEDTHEMES%"
fi

php -f bin/magento $DEPLOY_COMMAND

# Generate static assets for Admin theme
php -f bin/magento setup:static-content:deploy en_US --theme Magento/backend

# Generate SASS
cd vendor/snowdog/frontools
yarn install
gulp styles --disableMaps --prod