#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/english-braids.localhost.com/scripts
# $ ./update/10-prepare-composer.sh
set -a; . `pwd`/config-m2.env
cd $MAGENTO2_ENV_WEBROOT

# Remove customer access to site (whitelisted IPs can still access frontend/backend)
bin/magento maintenance:enable

# Don't remove the files we just generated
bin/magento setup:upgrade --keep-generated
bin/magento setup:db-schema:upgrade
bin/magento setup:db-data:upgrade

# Allow access to site again
bin/magento maintenance:disable
