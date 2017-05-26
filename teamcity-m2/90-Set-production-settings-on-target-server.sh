#!/usr/bin/env bash

#
# Team City build step configuration
#
# Runner Type:          Command Line
# Step name:            90: Set production settings on target server
# Execute Step:         If all previous steps finished successfully (zero exit code)
# Working directory:    htdocs
# Run:                  Custom script
# Custom script:        See below
#

ssh administrator@%env.MAGENTO2_ENV_HOSTNAME% << EOF
cd %env.MAGENTO2_ENV_WEBROOT%

# Enable all caches
sudo -u administrator php -f bin/magento cache:flush
sudo -u administrator php -f bin/magento cache:enable

# We skip compilation here because we've already done that in the previous step
sudo -u administrator php -f bin/magento deploy:mode:set production --skip-compilation

EOF