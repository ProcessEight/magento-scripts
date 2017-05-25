#!/usr/bin/env bash

#
# Team City build step configuration
#
# Runner Type:          Command Line
# Step name:            80: Update database on target server
# Execute Step:         If all previous steps finished successfully (zero exit code)
# Working directory:    htdocs
# Run:                  Custom script
# Custom script:        See below
#

ssh administrator@%env.MAGENTO2_ENV_HOSTNAME% << EOF
cd %env.MAGENTO2_ENV_WEBROOT%

# Remove customer access to site (whitelisted IPs can still access frontend/backend)
php -f bin/magento maintenance:enable

# Don't remove the files we just generated
php -f bin/magento setup:upgrade --keep-generated
php -f bin/magento setup:db-schema:upgrade
php -f bin/magento setup:db-data:upgrade

# Allow access to site again
php -f bin/magento maintenance:disable

echo "# Force correct permissions on files"
sudo find var vendor pub/static pub/media app/etc -type f -exec chmod u+w {} \;
echo "# Force correct permissions on directories"
sudo find var vendor pub/static pub/media app/etc -type d -exec chmod u+w {} \;
echo "# Force correct ownership on files"
sudo find var vendor pub/static pub/media app/etc -type f -exec chown %env.MAGENTO2_ENV_CLIUSER%:%env.MAGENTO2_ENV_WEBSERVERGROUP% {} \;
echo "# Force correct ownership on directories"
sudo find var vendor pub/static pub/media app/etc -type d -exec chown %env.MAGENTO2_ENV_CLIUSER%:%env.MAGENTO2_ENV_WEBSERVERGROUP% {} \;
echo "# Set the sticky bit to ensure that files are generated with the right ownership"
sudo find var vendor pub/static pub/media app/etc -type d -exec chmod g+s {} \;

if [[ ! -f n98-magerun2.phar ]]; then

    echo "
    #
    # Install magerun2
    #
    "
    cd %env.MAGENTO2_ENV_WEBROOT%
    wget https://files.magerun.net/n98-magerun2.phar && chmod +x ./n98-magerun2.phar
fi

# There's no way to set the theme using bin/magento or n98-magerun2, so do some nifty bash scripting to do it
THEME_ID="$(./n98-magerun2.phar dev:theme:list --format=csv | grep 'Purenet/EnglishBraids' | cut -d, -f1)"; test -n "${THEME_ID}" && ./n98-magerun2.phar config:set design/theme/theme_id "${THEME_ID}"

EOF