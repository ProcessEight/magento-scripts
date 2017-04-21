#!/usr/bin/env bash
set -a; . config.env
cd $MAGENTO2_ENV_WEBROOT

# Make sure we can execute the CLI tool
chmod u+x bin/magento
# Force correct permissions on files
find var vendor pub/static pub/media app/etc -type f -exec chmod u+w {} \;
# Force correct permissions on directories
find var vendor pub/static pub/media app/etc -type d -exec chmod u+w {} \;
# Force correct ownership on files
find var vendor pub/static pub/media app/etc -type f -exec chown $MAGENTO2_ENV_CLIUSER:$MAGENTO2_ENV_WEBSERVERGROUP {} \;
# Force correct ownership on directories
find var vendor pub/static pub/media app/etc -type d -exec chown $MAGENTO2_ENV_CLIUSER:$MAGENTO2_ENV_WEBSERVERGROUP {} \;
# Set the sticky bit to ensure that files are generated with the right ownership
find var vendor pub/static pub/media app/etc -type d -exec chmod g+s {} \;

# Make sure Magento 2 is installed.
# Reads the composer.lock file and installs/updates all dependencies to the specified version
composer install

# This script assumes the tools needed to compile SASS to CSS are already installed
# If not however, they can be installed using the following commands
#curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
#echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
#sudo apt-get update && sudo apt-get install yarn
#cd $MAGENTO2_ENV_WEBROOT/vendor/snowdog/frontools
#rm -rf node_modules
#yarn
