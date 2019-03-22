#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/your-project.local/scripts
# $ ./update/10-prepare-composer.sh
set -a; . `pwd`/config-m1.env

rm -rf $MAGENTO1_ENV_WEBROOT

mysql -u root -e "DROP DATABASE $MAGENTO1_DB_NAME"
mysql -u root -e "DROP USER '$MAGENTO1_DB_USERNAME'@'$MAGENTO1_DB_HOSTNAME'"
