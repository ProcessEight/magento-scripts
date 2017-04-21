#!/usr/bin/env bash
set -a; . update.env
cd $MAGENTO2_ENV_WEBROOT

find var vendor pub/static pub/media app/etc -type f -exec chmod u+w {} \;
find var vendor pub/static pub/media app/etc -type d -exec chmod u+w {} \;
chmod u+x bin/magento

# Make sure Magento 2 is installed.
# Reads the composer.lock file and installs/updates all dependencies to the specified version
composer install

# This script assumes the tools needed to compile SASS to CSS are already installed
# If not however, they can be installed usign the following commands
#cd $MAGENTO2_ENV_WEBROOT/vendor/snowdog/frontools
#rm -rf node_modules
#yarn