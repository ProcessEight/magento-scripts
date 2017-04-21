#!/usr/bin/env bash
set -a; . update.env

if [[ $MAGENTO2_DB_BACKUPFIRST ]];
then mysqldump -u root --password=password $MAGENTO2_DB_NAME > $MAGENTO2_DB_NAME.bak.sql
fi