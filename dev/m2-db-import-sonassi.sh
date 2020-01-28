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

if $MAGENTO2_DB_RESET; then

echo "
#
# Prepare database
#
"
    echo "#"
    echo "# Running query: DROP DATABASE IF EXISTS $MAGENTO2_DB_NAME; CREATE DATABASE $MAGENTO2_DB_NAME"
    echo "#"
    mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "DROP DATABASE IF EXISTS $MAGENTO2_DB_NAME; CREATE DATABASE $MAGENTO2_DB_NAME"

    echo "#"
    echo "# Check if the user exists and if not, create a dummy user with a harmless privilege which we'll drop in the next step"
    echo "# This prevents MySQL from issuing an error if the user does not exist"
    echo "# Running query: GRANT USAGE ON *.* TO '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME' IDENTIFIED BY '$MAGENTO2_DB_PASSWORD'"
    echo "#"
    mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "GRANT USAGE ON *.* TO '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME' IDENTIFIED BY '$MAGENTO2_DB_PASSWORD'"

    echo "#"
    echo "# Running query: DROP USER '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME'"
    echo "#"
    mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "DROP USER '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME'"

    echo "#"
    echo "# Running query: CREATE USER '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME' IDENTIFIED BY '$MAGENTO2_DB_PASSWORD'"
    echo "#"
    mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "CREATE USER '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME' IDENTIFIED BY '$MAGENTO2_DB_PASSWORD'"

    echo "#"
    echo "# Running query: GRANT ALL PRIVILEGES ON $MAGENTO2_DB_NAME.* TO '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME'"
    echo "#"
    mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "GRANT ALL PRIVILEGES ON $MAGENTO2_DB_NAME.* TO '$MAGENTO2_DB_USERNAME'@'$MAGENTO2_DB_HOSTNAME'"

    echo "#"
    echo "# Avoid the 'show_compatibility_56' error"
    echo "#"
    mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "SET global show_compatibility_56 = on"
fi

if $MAGENTO2_DB_IMPORT; then

echo "
#
# Processing db backup
#
"

echo "# Create a new db dump file in the M2 var directory"
cd $MAGENTO2_ENV_WEBROOT/var/

echo "# Concat the uncompressed db structure dump into the above file"
pbzip2 -dc tredm2_magdev_structure.sql.bz2 >> db.sql || exit

echo "# Concat the uncompressed db data dump into the above file"
pbzip2 -dc tredm2_magdev_data.sql.bz2 >> db.sql || exit

echo "# Switch back to M2 root (where the mage2-dbdump.sh script should be)"
cd $MAGENTO2_ENV_WEBROOT

echo "# Update definers"
sed -i 's/`tredm2_magdev`@`172.16.%`/CURRENT_USER/g' $MAGENTO2_ENV_WEBROOT/var/db.sql

echo "
#
# Restoring database
#
"

./mage2-dbdump.sh -r || exit

# Update the URLs
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD $MAGENTO2_DB_NAME -e "UPDATE core_config_data SET value = 'http://$MAGENTO2_ENV_HOSTNAME/' WHERE value = 'https://m2.t-pass.co.uk/'"
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD $MAGENTO2_DB_NAME -e "UPDATE core_config_data SET value = 'http://$MAGENTO2_ENV_HOSTNAME/us/' WHERE value = 'https://m2.t-pass.co.uk/us/'"
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD $MAGENTO2_DB_NAME -e "UPDATE core_config_data SET value = 'http://$MAGENTO2_ENV_HOSTNAME/row/' WHERE value = 'https://m2.t-pass.co.uk/row/'"
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD $MAGENTO2_DB_NAME -e "UPDATE core_config_data SET value = 'http://$MAGENTO2_ENV_HOSTNAME/pl/' WHERE value = 'https://m2.t-pass.co.uk/pl/'"
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD $MAGENTO2_DB_NAME -e "UPDATE core_config_data SET value = 0 WHERE path = 'web/secure/use_in_frontend'"
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD $MAGENTO2_DB_NAME -e "UPDATE core_config_data SET value = 0 WHERE path = 'web/secure/use_in_adminhtml'"

fi
