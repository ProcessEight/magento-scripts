#!/usr/bin/env bash
set -a; . config.env

mysql -u root -e "create database $MAGENTO2_DB_NAME"
mysql -u root -e "create user '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME' identified by '$MAGENTO2_DB_PASSWORD'"
mysql -u root -e "grant all privileges on $MAGENTO2_DB_NAME.* to '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME'"