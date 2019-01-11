#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/english-braids.localhost.com/scripts
# $ ./update/10-prepare-composer.sh
set -a; . `pwd`/config-m2.env

mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "DROP DATABASE IF EXISTS $MAGENTO2_DB_NAME; CREATE DATABASE $MAGENTO2_DB_NAME"

# Check if the user exists and if not, create a dummy user with a harmless privilege which we'll drop in the next step
# This prevents MySQL from issuing an error if the user does not exist
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "GRANT USAGE ON *.* TO '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME' IDENTIFIED BY '$MAGENTO2_DB_PASSWORD'"
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "DROP USER '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME'"
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "CREATE USER '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME' IDENTIFIED BY '$MAGENTO2_DB_PASSWORD'"
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "GRANT ALL PRIVILEGES ON $MAGENTO2_DB_NAME.* TO '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME'"
