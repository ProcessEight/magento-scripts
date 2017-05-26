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

# Remove customer access to site (whitelisted IPs can stils -lah access frontend/backend)
sudo -u administrator php -f bin/magento maintenance:enable

# Don't remove the files we just generated
sudo -u administrator php -f bin/magento setup:upgrade --keep-generated
ls -lah /var/www/html/englishbraids/htdocs/var/cache/mage-tags/

sudo -u administrator php -f bin/magento setup:db-schema:upgrade
ls -lah /var/www/html/englishbraids/htdocs/var/cache/mage-tags/

sudo -u administrator php -f bin/magento setup:db-data:upgrade
ls -lah /var/www/html/englishbraids/htdocs/var/cache/mage-tags/

# Allow access to site again
sudo -u administrator php -f bin/magento maintenance:disable
ls -lah /var/www/html/englishbraids/htdocs/var/cache/mage-tags/

cd %env.MAGENTO2_ENV_WEBROOT%
ls -lah /var/www/html/englishbraids/htdocs/var/cache/mage-tags/
#if [[ ! -f ./n98-magerun2.phar ]]; then
#    echo "# Install magerun2"
#    wget https://files.magerun.net/n98-magerun2.phar && chmod +x ./n98-magerun2.phar
#fi

# There's no way to set the theme using bin/magento or n98-magerun2, so do some nifty bash scripting to do it
#THEME_ID=$(./n98-magerun2.phar dev:theme:list --format=csv | grep 'Purenet/EnglishBraids' | cut -d, -f1)
ls -lah /var/www/html/englishbraids/htdocs/var/cache/mage-tags/

./n98-magerun2.phar config:set design/theme/theme_id 4
ls -lah /var/www/html/englishbraids/htdocs/var/cache/mage-tags/
EOF