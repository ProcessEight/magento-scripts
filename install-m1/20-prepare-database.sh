#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/your-project.local/scripts
# $ ./update/10-prepare-composer.sh
CONFIG_M1_FILEPATH=`pwd`/config-m1.env
if [[ ! -f $CONFIG_M1_FILEPATH ]]; then
    echo "
#
# Could not detect config-m1.env.
# Create one first in $CONFIG_M1_FILEPATH
# Script cannot continue. Exiting now
#
"
exit
fi
set -a; . `pwd`/config-m1.env

echo "
#
# 2. Prepare database
#
"

echo "Creating database...";
mysql $MAGENTO1_DB_ROOTUSERNAME $MAGENTO1_DB_ROOTPASSWORD -e "create database $MAGENTO1_DB_NAME"
echo "Creating user...";
mysql $MAGENTO1_DB_ROOTUSERNAME $MAGENTO1_DB_ROOTPASSWORD -e "create user '$MAGENTO1_DB_USERNAME'@'$MAGENTO1_DB_HOSTNAME' identified by '$MAGENTO1_DB_PASSWORD'"
echo "Granting permissions on user...";
mysql $MAGENTO1_DB_ROOTUSERNAME $MAGENTO1_DB_ROOTPASSWORD -e "grant all privileges on $MAGENTO1_DB_NAME.* to '$MAGENTO1_DB_USERNAME'@'$MAGENTO1_DB_HOSTNAME'"
if [[ $MAGENTO1_ENV_INSTALLSAMPLEDATA == true ]]; then
    echo "Installing sample data from $MAGENTO1_ENV_WEBROOT/../scripts/install-m1/magento-sample-data-$SAMPLEDATA_VERSION/magento_sample_data_for_$SAMPLEDATA_VERSION.sql"
    mysql $MAGENTO1_DB_ROOTUSERNAME $MAGENTO1_DB_ROOTPASSWORD $MAGENTO1_DB_NAME < $MAGENTO1_ENV_WEBROOT/../scripts/install-m1/magento-sample-data-$SAMPLEDATA_VERSION/magento_sample_data_for_$SAMPLEDATA_VERSION.sql
else
    echo "Restoring database using mage-dbdump.sh...";
    cd $MAGENTO1_ENV_WEBROOT
    if [[ ! -f $MAGENTO1_ENV_WEBROOT/mage-dbdump.sh ]]; then
        wget sys.sonassi.com/mage-dbdump.sh && chmod +x ./mage-dbdump.sh
    fi
    $MAGENTO1_ENV_WEBROOT/mage-dbdump.sh -rz
fi
