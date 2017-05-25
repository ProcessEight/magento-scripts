#!/usr/bin/env bash

#
# Team City build step configuration
#
# Runner Type:          Command Line
# Step name:            60: Deploy to target server
# Execute Step:         If all previous steps finished successfully (zero exit code)
# Working directory:    htdocs
# Run:                  Custom script
# Custom script:        See below
#

rsync -vrztl --omit-dir-times --safe-links -e ssh 'htdocs/' administrator@%env.MAGENTO2_ENV_HOSTNAME%:%env.MAGENTO2_ENV_WEBROOT%

ssh administrator@%env.MAGENTO2_ENV_HOSTNAME% << EOF
cd %env.MAGENTO2_ENV_WEBROOT%

# The login-path 'local' must already have been configured on the target server using the command:
# $ mysql_config_editor set --login-path=staging --host=localhost --user=root --password
# This avoids us having to use the password on the command line or as a build environment variable
DOES_DB_EXIST=$(mysql --login-path=local -e "show databases like '%env.MAGENTO2_DB_NAME%'")
echo "DOES_DB_EXIST: $DOES_DB_EXIST"
if [[ "" == "$DOES_DB_EXIST" ]]; then
    echo "create database %env.MAGENTO2_DB_NAME%"
    mysql --login-path=local -e "create database %env.MAGENTO2_DB_NAME%"
    echo "create user '%env.MAGENTO2_DB_USERNAME%'@'%env.MAGENTO2_DB_HOSTNAME%' identified by '%env.MAGENTO2_DB_PASSWORD%'"
    mysql --login-path=local -e "create user '%env.MAGENTO2_DB_USERNAME%'@'%env.MAGENTO2_DB_HOSTNAME%' identified by '%env.MAGENTO2_DB_PASSWORD%'"
    echo "grant all privileges on %env.MAGENTO2_DB_NAME%.* to '%env.MAGENTO2_DB_USERNAME%'@'%env.MAGENTO2_DB_HOSTNAME%'"
    mysql --login-path=local -e "grant all privileges on %env.MAGENTO2_DB_NAME%.* to '%env.MAGENTO2_DB_USERNAME%'@'%env.MAGENTO2_DB_HOSTNAME%'"
fi

# Composer parallel install plugin
# Add this using composer require
#composer global require hirak/prestissimo

cd %env.MAGENTO2_ENV_WEBROOT%

# Install the project
# Reads the composer.lock file and installs/updates all dependencies to the specified version
composer install

#php -f bin/magento deploy:mode:set developer

#php -f bin/magento module:enable --all

#echo "# Force correct permissions on files"
#sudo find var vendor pub/static pub/media app/etc -type f -exec chmod u+w {} \;
#echo "# Force correct permissions on directories"
#sudo find var vendor pub/static pub/media app/etc -type d -exec chmod u+w {} \;
#echo "# Force correct ownership on files"
#sudo find var vendor pub/static pub/media app/etc -type f -exec chown %env.MAGENTO2_ENV_CLIUSER%:%env.MAGENTO2_ENV_WEBSERVERGROUP% {} \;
#echo "# Force correct ownership on directories"
#sudo find var vendor pub/static pub/media app/etc -type d -exec chown %env.MAGENTO2_ENV_CLIUSER%:%env.MAGENTO2_ENV_WEBSERVERGROUP% {} \;
#echo "# Set the sticky bit to ensure that files are generated with the right ownership"
#sudo find var vendor pub/static pub/media app/etc -type d -exec chmod g+s {} \;

YARN_COMMAND=$(which yarn)
echo "YARN_COMMAND: $YARN_COMMAND"
if [[ "" == "$YARN_COMMAND" ]]; then
    echo "# Yarn not found; Installing Yarn"
    curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
    echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
    sudo apt-get update && sudo apt-get install -y yarn
fi

echo "Running yarn install"
cd %env.MAGENTO2_ENV_WEBROOT%/vendor/snowdog/frontools
yarn install

EOF