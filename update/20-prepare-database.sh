#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/english-braids.localhost.com/scripts
# $ ./update/10-prepare-composer.sh
set -a; . `pwd`/config-m2.env

if [[ $MAGENTO2_DB_BACKUPFIRST == "true" ]];
then mysqldump -u root --password=password $MAGENTO2_DB_NAME > $MAGENTO2_DB_NAME.bak.sql
fi
