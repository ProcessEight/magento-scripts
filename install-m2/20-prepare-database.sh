#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/english-braids.localhost.com/scripts
# $ ./update/10-prepare-composer.sh
set -a; . `pwd`/config-m2.env

mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "create database $MAGENTO2_DB_NAME"
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "create user '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME' identified by '$MAGENTO2_DB_PASSWORD'"
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "grant all privileges on $MAGENTO2_DB_NAME.* to '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME'"