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

echo "
#
# 25. Setup integration tests database
#
"

mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "DROP DATABASE IF EXISTS $MAGENTO2_INTEGRATION_TESTS_DB_NAME; CREATE DATABASE $MAGENTO2_INTEGRATION_TESTS_DB_NAME"

# Check if the user exists and if not, create a dummy user with a harmless privilege which we'll drop in the next step
# This prevents MySQL from issuing an error if the user does not exist
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "GRANT USAGE ON *.* TO '$MAGENTO2_INTEGRATION_TESTS_DB_USERNAME'@'$MAGENTO2_INTEGRATION_TESTS_DB_HOSTNAME' IDENTIFIED BY '$MAGENTO2_INTEGRATION_TESTS_DB_PASSWORD'"
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "DROP USER '$MAGENTO2_INTEGRATION_TESTS_DB_USERNAME'@'$MAGENTO2_INTEGRATION_TESTS_DB_HOSTNAME'"
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "CREATE USER '$MAGENTO2_INTEGRATION_TESTS_DB_USERNAME'@'$MAGENTO2_INTEGRATION_TESTS_DB_HOSTNAME' IDENTIFIED BY '$MAGENTO2_INTEGRATION_TESTS_DB_PASSWORD'"
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "GRANT ALL PRIVILEGES ON $MAGENTO2_INTEGRATION_TESTS_DB_NAME.* TO '$MAGENTO2_INTEGRATION_TESTS_DB_USERNAME'@'$MAGENTO2_INTEGRATION_TESTS_DB_HOSTNAME'"
