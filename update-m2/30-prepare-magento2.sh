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

echo "# Set the group-id bit to ensure that files and directories are generated with the right ownership..."
sudo find var generated pub/static pub/media app/etc -type f -exec chmod g+w {} + &&
sudo find var generated pub/static pub/media app/etc -type d -exec chmod g+ws {} +
echo "# Ensure a clean slate by flushing selected directories..."
sudo rm -rf generated/code/ var/cache/ pub/static/* pub/media/*