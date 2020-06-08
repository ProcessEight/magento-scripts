#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/your-project.local/scripts
# $ ./update/10-prepare-composer.sh
CONFIG_M2_FILEPATH=`pwd`/config-pr.env
PROJECT_ROOT_PATH=`pwd`
# Check we are in the right directory
if [[ 'scripts' != ${PROJECT_ROOT_PATH: -7} ]]; then
    echo "
#
# The script detected you are running this script from an invalid location.
# Make sure you are running this script from the scripts directory.
# The script detected $PROJECT_ROOT_PATH
#
# Script cannot continue. Exiting now.
#"
  exit
fi

# Check that config file exists
if [[ ! -f $CONFIG_M2_FILEPATH ]]; then
    echo "
#
# Could not detect config-m2.env.
# Create one first in $PROJECT_ROOT_PATH/config-m2.env
# and make sure you are running this script from the scripts directory.
#
# Script cannot continue. Exiting now.
#"
  exit
fi

# Load config variables
set -a; . `pwd`/config-pr.env

#
# Script-specific logic starts here
#

echo "
#
# Switching to $MAGENTO2_ENV_WEBROOT
#
"
cd $MAGENTO2_ENV_WEBROOT || exit # Exit if 'cd' command fails

echo "
#
# Prepare magento instance
#
"

# Force checkout develop branch
git checkout --force develop --
# Update dev branch
git fetch origin --recurse-submodules=no --progress --prune
# Remove modules from app/code/ to prevent errors if the module has been added to vendor/trespass/
rm -rf app/code/Trespass/*
# Remove and re-install vendor/trespass/ to flush out any customisations made in vendor/trespass/
rm -rf $MAGENTO2_ENV_WEBROOT/vendor/trespass/ && $MAGENTO2_ENV_COMPOSERCOMMAND install

echo "
#
# Prepare module being PR'd
#
"

# Switch to modules directory
cd /var/www/html/jacobs-turner/modules/$GIT_MODULE_NAME/
# Force checkout master branch
git checkout --force master --
# Update branch
git fetch origin --recurse-submodules=no --progress --prune
git merge origin/master --no-stat -v
# Switch to PR branch
git checkout --force -b $GIT_PR_BRANCH_NAME
# Copy everything to vendor/
cd $MAGENTO2_ENV_WEBROOT
cp -rf /var/www/html/jacobs-turner/modules/$GIT_MODULE_NAME/* $MAGENTO2_ENV_WEBROOT/vendor/trespass/$COMPOSER_MODULE_NAME/
# Enable module
/usr/bin/php7.3 -v && /usr/bin/php7.3 /var/www/html/n98-magerun2.phar --ansi mod:en $MAGENTO2_MODULE_NAME

echo "
#
# Reset everything
#
"

xddphp73 && cd $MAGENTO2_ENV_WEBROOT/../scripts/ && ./dev/reset-everything.sh
cd $MAGENTO2_ENV_WEBROOT
