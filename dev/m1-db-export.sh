#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/magento1-project/scripts
# $ ./dev/myin.sh
CONFIG_M1_FILEPATH=`pwd`/config-m1.env
if [[ ! -f $CONFIG_M1_FILEPATH ]]; then
    echo "
#
# Could not detect config-m1.env.
# Create one first in $CONFIG_M1_FILEPATH
# Script cannot continue. Exiting now.
#
"
exit
fi
set -a; . `pwd`/config-m1.env

mysqldump $MAGENTO1_DB_ROOTUSERNAME $MAGENTO1_DB_ROOTPASSWORD $MAGENTO1_DB_NAME --no-create-info --skip-triggers catalog_product_entity_decimal catalog_product_option_type_price  | pv --progress --size 100m > $MAGENTO1_DB_DUMPNAME
