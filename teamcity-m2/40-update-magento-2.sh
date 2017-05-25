#!/usr/bin/env bash

#
# Team City build step configuration
#
# Runner Type:          Command Line
# Step name:            40: Update Magento 2
# Execute Step:         If all previous steps finished successfully (zero exit code)
# Working directory:    htdocs
# Run:                  Custom script
# Custom script:        See below
#

# Install the project
# Reads the composer.lock file and installs/updates all dependencies to the specified version
composer install

php -f bin/magento module:enable --all