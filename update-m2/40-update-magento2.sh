#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/english-braids.localhost.com/scripts
# $ ./update/10-prepare-composer.sh
set -a; . `pwd`/config-m2.env
cd $MAGENTO2_ENV_WEBROOT

# Install the project
# Reads the composer.lock file and installs/updates all dependencies to the specified version
composer install

# Make sure we can execute the CLI tool
chmod u+x bin/magento
bin/magento module:enable --all