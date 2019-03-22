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
# 20. Prepare database
#
"

if [[ $MAGENTO2_DB_BACKUPFIRST == true ]]; then
    mysqldump $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD $MAGENTO2_DB_NAME > $MAGENTO2_DB_NAME.bak.sql
fi

if [[ $MAGENTO2_DB_RESET == true ]]; then
    echo "# Remove existing database"
    echo "# DROP DATABASE IF EXISTS $MAGENTO2_DB_NAME"
    mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "DROP DATABASE IF EXISTS $MAGENTO2_DB_NAME"

    echo "# Check if the user exists and if not, create a dummy user with a harmless privilege which we'll drop in the next step"
    echo "# This prevents MySQL from issuing an error if the user does not exist"
    echo "# GRANT USAGE ON *.* TO '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME' IDENTIFIED BY '$MAGENTO2_DB_PASSWORD'"
    echo "# DROP USER '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME'"
    mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "GRANT USAGE ON *.* TO '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME' IDENTIFIED BY '$MAGENTO2_DB_PASSWORD'"
    mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "DROP USER '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME'"

    echo "# Create new database and user"
    echo "# CREATE DATABASE $MAGENTO2_DB_NAME"
    echo "# CREATE USER '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME' IDENTIFIED BY '$MAGENTO2_DB_PASSWORD'"
    echo "# GRANT ALL PRIVILEGES ON $MAGENTO2_DB_NAME.* TO '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME'"
    mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "CREATE DATABASE $MAGENTO2_DB_NAME"
    mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "CREATE USER '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME' IDENTIFIED BY '$MAGENTO2_DB_PASSWORD'"
    mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "GRANT ALL PRIVILEGES ON $MAGENTO2_DB_NAME.* TO '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME'"
fi

if [[ $MAGENTO2_DB_IMPORT == true ]]; then
    echo "# Importing database dump"
    pv $MAGENTO2_DB_DUMPNAME | mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD $MAGENTO2_DB_NAME
fi