#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/english-braids.localhost.com/scripts
# $ ./update/10-prepare-composer.sh
set -a; . `pwd`/config-m2.env
cd $MAGENTO2_ENV_WEBROOT

# Composer parallel install plugin
composer global require hirak/prestissimo

# Install the project
# Reads the composer.lock file and installs/updates all dependencies to the specified version
composer install

bin/magento module:enable --all