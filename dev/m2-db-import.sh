#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/magento2-project/scripts
# $ ./dev/myin.sh
CONFIG_M2_FILEPATH=`pwd`/config-m2.env
if [[ ! -f $CONFIG_M2_FILEPATH ]]; then
    echo "
#
# Could not detect config-m2.env.
# Create one first in $CONFIG_M2_FILEPATH
# Script cannot continue. Exiting now.
#
"
exit
fi
set -a; . `pwd`/config-m2.env
pv $MAGENTO2_DB_DUMPNAME | mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD $MAGENTO2_DB_NAME
