#!/usr/bin/env bash

#
# Team City build step configuration
#
# Runner Type:          Command Line
# Step name:            30: Prepare Magento 2
# Execute Step:         If all previous steps finished successfully (zero exit code)
# Working directory:    htdocs
# Run:                  Custom script
# Custom script:        See below
#

# Force correct permissions on files
#find var vendor pub/static pub/media app/etc -type f -exec chmod u+w {} \;
# Force correct permissions on directories
#find var vendor pub/static pub/media app/etc -type d -exec chmod u+w {} \;
# Force correct ownership on files
#find var vendor pub/static pub/media app/etc -type f -exec chown %env.MAGENTO2_ENV_CLIUSER%:%env.MAGENTO2_ENV_WEBSERVERGROUP% {} \;
# Force correct ownership on directories
#find var vendor pub/static pub/media app/etc -type d -exec chown %env.MAGENTO2_ENV_CLIUSER%:%env.MAGENTO2_ENV_WEBSERVERGROUP% {} \;
# Set the sticky bit to ensure that files are generated with the right ownership
#find var vendor pub/static pub/media app/etc -type d -exec chmod g+s {} \;

# This script assumes the tools needed to compile SASS to CSS are already installed
# If not however, they can be installed using the following commands
#curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
#echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
#sudo apt-get update -y && sudo apt-get install -y yarn
#cd vendor/snowdog/frontools
#yarn install