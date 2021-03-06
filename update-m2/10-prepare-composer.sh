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

cd $MAGENTO2_ENV_WEBROOT

echo "
#
# 10. Prepare composer
#
"

COMPOSER_CMD=$(which composer)
if [[ "" == "$COMPOSER_CMD" ]]; then
    echo "
#
# Could not detect Composer.
# Make sure composer is installed and then try again.
#
# Script cannot continue. Exiting now.
#
"
exit
fi

#if [[ ! -f ~/.composer/auth.json ]]; then
#    echo "
##
## Adding repo.magento.com access keys to ~/.composer/auth.json...
##
#"
#    mkdir -p ~/.composer/
#
#    echo "{
#       \"http-basic\": {
#          \"repo.magento.com\": {
#             \"username\": \"$MAGENTO2_PUBLIC_KEY\",
#             \"password\": \"$MAGENTO2_PRIVATE_KEY\"
#          }
#       }
#    }" > ~/.composer/auth.json
#fi
