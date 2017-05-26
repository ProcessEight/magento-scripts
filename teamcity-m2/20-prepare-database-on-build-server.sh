#!/usr/bin/env bash

#
# Team City build step configuration
#
# Runner Type:          Command Line
# Step name:            20: Prepare Database on build server
# Execute Step:         If all previous steps finished successfully (zero exit code)
# Working directory:    htdocs
# Run:                  Custom script
# Custom script:        See below
#

#MYSQL_COMMAND=$(which mysql)
#if [[ "" == "$MYSQL_COMMAND" ]]; then
#    # TODO: Implement that bit about debconf-set-selections to inject the root password when it asks for it
#    wget https://repo.percona.com/apt/percona-release_0.1-4.$(lsb_release -sc)_all.deb
#    sudo dpkg -i percona-release_0.1-4.$(lsb_release -sc)_all.deb
#    sudo apt-get update
#    sudo apt-get install percona-server-server-5.7
#fi;

#echo "create database %env.MAGENTO2_DB_NAME%"
mysql -u root --password=password123 -e "create database %env.MAGENTO2_DB_NAME%"
#echo "create user '%env.MAGENTO2_DB_USERNAME%'@'%env.MAGENTO2_DB_HOSTNAME%' identified by '%env.MAGENTO2_DB_PASSWORD%'"
mysql -u root --password=password123 -e "create user '%env.MAGENTO2_DB_USERNAME%'@'%env.MAGENTO2_DB_HOSTNAME%' identified by '%env.MAGENTO2_DB_PASSWORD%'"
#echo "grant all privileges on %env.MAGENTO2_DB_NAME%.* to '%env.MAGENTO2_DB_USERNAME%'@'%env.MAGENTO2_DB_HOSTNAME%'"
mysql -u root --password=password123 -e "grant all privileges on %env.MAGENTO2_DB_NAME%.* to '%env.MAGENTO2_DB_USERNAME%'@'%env.MAGENTO2_DB_HOSTNAME%'"
