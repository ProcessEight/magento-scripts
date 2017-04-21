#!/usr/bin/env bash
set -a; . config.env
cd $MAGENTO2_ENV_WEBROOT

# Remove customer access to site (whitelisted IPs can still access frontend/backend)
cd $MAGENTO2_ENV_WEBROOT
bin/magento maintenance:enable

# Don't remove the files we just generated
bin/magento setup:upgrade --keep-generated
bin/magento setup:db-schema:upgrade
bin/magento setup:db-data:upgrade

# Allow access to site again
bin/magento maintenance:disable
