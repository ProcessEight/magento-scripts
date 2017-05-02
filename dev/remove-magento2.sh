#!/usr/bin/env bash
set -a; . `pwd`/config-m2.env

rm -rf $MAGENTO2_ENV_WEBROOT

mysql -u root --password=password -e "DROP DATABASE $MAGENTO2_DB_NAME"
mysql -u root --password=password -e "DROP USER '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME'"