#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/your-project.local/scripts
# $ ./update/10-prepare-composer.sh
CONFIG_M2_FILEPATH=`pwd`/config-m2.env
PROJECT_ROOT_PATH=`pwd`
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
set -a; . `pwd`/config-m2.env

#
# Script-specific logic starts here
#

cd $MAGENTO2_ENV_WEBROOT || exit

# Enable all caches
bin/magento cache:enable
bin/magento cache:flush

# We skip compilation here because we've already done in the previous step
bin/magento deploy:mode:set production --skip-compilation

if [[ $MAGENTO2_ENV_ENABLECRON == true ]]; then
  echo "
#
# Enabling Magento 2 cron
#
"
  $MAGENTO2_ENV_PHPCOMMAND -f bin/magento cron:install
  $MAGENTO2_ENV_PHPCOMMAND -f bin/magento setup:cron:run
fi
