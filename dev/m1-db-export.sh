#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/your-project.local/scripts
# $ ./update/10-prepare-composer.sh
CONFIG_M1_FILEPATH=`pwd`/config-m1.env
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
if [[ ! -f $CONFIG_M1_FILEPATH ]]; then
    echo "
#
# Could not detect config-m1.env.
# Create one first in $PROJECT_ROOT_PATH/config-m1.env
# and make sure you are running this script from the scripts directory.
#
# Script cannot continue. Exiting now.
#"
exit
fi
set -a; . `pwd`/config-m1.env

#
# Script-specific logic starts here
#

mysqldump $MAGENTO1_DB_ROOTUSERNAME $MAGENTO1_DB_ROOTPASSWORD $MAGENTO1_DB_NAME --no-create-info --skip-triggers catalog_product_entity_decimal catalog_product_option_type_price  | pv --progress --size 100m > $MAGENTO1_DB_DUMPNAME
