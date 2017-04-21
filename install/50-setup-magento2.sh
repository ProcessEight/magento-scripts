#!/usr/bin/env bash
set -a; . config.env
cd $MAGENTO2_ENV_WEBROOT

# Remove customer access to site (whitelisted IPs can still access frontend/backend)
bin/magento maintenance:enable

# Force correct ownership on files
#find var vendor pub/static pub/media app/etc -type f -exec chown $MAGENTO2_ENV_CLIUSER:$MAGENTO2_ENV_WEBSERVERGROUP {} \;
# Force correct ownership on directories
#find var vendor pub/static pub/media app/etc -type d -exec chown $MAGENTO2_ENV_CLIUSER:$MAGENTO2_ENV_WEBSERVERGROUP {} \;

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
# Exclude configured themes
if [[ $MAGENTO2_STATICCONTENTDEPLOY_EXCLUDE ]]; then
    DEPLOY_COMMAND="$DEPLOY_COMMAND --exclude-theme $MAGENTO2_STATICCONTENTDEPLOY_EXCLUDE"
fi
bin/magento $DEPLOY_COMMAND
# Generate static assets for Admin theme
bin/magento setup:static-content:deploy en_US --theme Magento/backend

# Generate SASS
cd $MAGENTO2_ENV_WEBROOT/vendor/snowdog/frontools
gulp styles --disableMaps --prod
