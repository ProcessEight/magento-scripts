#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/english-braids.localhost.com/scripts
# $ ./update/10-prepare-composer.sh
set -a; . `pwd`/config-m2.env

rm -rf $MAGENTO2_ENV_WEBROOT

mysql -u root -e "DROP DATABASE $MAGENTO2_DB_NAME"
mysql -u root -e "DROP USER '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME'"
