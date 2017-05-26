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

# Install the project
# Reads the composer.lock file and installs/updates all dependencies to the specified version
#composer install

EOF