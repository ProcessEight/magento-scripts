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

# This script assumes the tools needed to compile SASS to CSS are already installed
# If not however, they can be installed using the following commands
#curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
#echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
#sudo apt-get update -y && sudo apt-get install -y yarn
#cd vendor/snowdog/frontools
#yarn install