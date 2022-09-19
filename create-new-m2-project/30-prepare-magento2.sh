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
# 30. Prepare Magento 2
#
"

if [[ ! -d $MAGENTO2_ENV_WEBROOT ]]; then
    mkdir -p $MAGENTO2_ENV_WEBROOT

    echo "# Create a new, blank Magento 2 install"
    $MAGENTO2_ENV_COMPOSERCOMMAND create-project --repository-url=https://repo.magento.com/ magento/project-$MAGENTO2_ENV_EDITION-edition $MAGENTO2_ENV_WEBROOT $MAGENTO2_ENV_VERSION || exit
else
    echo "
#
# The script has detected that the $MAGENTO2_ENV_WEBROOT directory already exists.
# The script will not overwrite existing files.
# To continue, move, rename or delete the $MAGENTO2_ENV_WEBROOT directory.
#
# Script cannot continue. Exiting now.
"
    exit
fi;

cd $MAGENTO2_ENV_WEBROOT || exit

if [[ ! -d $MAGENTO2_ENV_WEBROOT ]]; then
    echo "
#
# The script has detected that the $MAGENTO2_ENV_WEBROOT directory does not exist.
#
# To continue, verify permissions and ownership and try again.
#
# Script cannot continue. Exiting now.
#"
    exit
fi

if [[ ! -f $MAGENTO2_ENV_WEBROOT/bin/magento ]]; then
    echo "
#
# The script has detected that the $MAGENTO2_ENV_WEBROOT/bin/magento file does not exist.
#
# This indicates that the installation of Magento 2 has failed.
#
# To continue, verify your Composer settings, remove the install directory ($MAGENTO2_ENV_WEBROOT) and try again.
#
# Script cannot continue. Exiting now.
#"
    exit
fi

cd $MAGENTO2_ENV_WEBROOT || exit

# Make sure we can execute the CLI tool
chmod u+x bin/magento

if [[ $MAGENTO2_ENV_RESETPERMISSIONS == true ]]; then
  echo "
#
# Updating file permissions...
#
"
  echo "# Set the group-id bit to ensure that files and directories are generated with the right ownership..."
  sudo find var generated pub/static pub/media app/etc -type f -exec chmod g+w {} + &&
    sudo find var generated pub/static pub/media app/etc -type d -exec chmod g+ws {} +
  echo "# Ensure a clean slate by flushing selected directories..."
  sudo rm -rf generated/code/ var/cache/ pub/static/* pub/media/*
fi
