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

# Cleanup
rm -f $MAGENTO2_ENV_WEBROOT/dev/tests/unit/etc/install-config-mysql.php
rm -f $MAGENTO2_ENV_WEBROOT/dev/tests/unit/phpunit.xml

echo "
#
# Setup $MAGENTO2_ENV_WEBROOT/dev/tests/unit/phpunit.xml
#
"

echo '<?xml version="1.0" encoding="UTF-8"?>
<phpunit xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:noNamespaceSchemaLocation="https://schema.phpunit.de/9.3/phpunit.xsd"
         colors="true"
         columns="max"
         beStrictAboutTestsThatDoNotTestAnything="false"
         bootstrap="./framework/bootstrap.php">
    <testsuites>
        <testsuite name="Magento_Unit_Tests_App_Code">
            <directory>../../../app/code/*/*/Test/Unit</directory>
            <directory>../../../vendor/magento/module-*/Test/Unit</directory>
            <exclude>../../../app/code/Magento/Indexer/Test/Unit</exclude>
        </testsuite>
        <testsuite name="Magento_Unit_Tests_App_Code_Indexer">
            <directory>../../../app/code/*/Indexer/Test/Unit</directory>
        </testsuite>
        <testsuite name="Magento_Unit_Tests_Other">
            <directory>../../../lib/internal/*/*/Test/Unit</directory>
            <directory>../../../lib/internal/*/*/*/Test/Unit</directory>
            <directory>../../../setup/src/*/*/Test/Unit</directory>
            <directory>../../../vendor/*/module-*/Test/Unit</directory>
            <directory>../../../vendor/*/framework/Test/Unit</directory>
            <directory>../../../vendor/*/framework/*/Test/Unit</directory>
            <directory>../../tests/unit/*/Test/Unit</directory>
        </testsuite>
        <testsuite name="'$MAGENTO2_ENV_HOSTNAME' Unit Tests">
            <directory>../../../app/code/*/*/Test/Unit</directory>
        </testsuite>
    </testsuites>
    <php>
        <includePath>.</includePath>
        <ini name="memory_limit" value="-1"/>
        <ini name="date.timezone" value="'$MAGENTO2_LOCALE_TIMEZONE'"/>
        <ini name="xdebug.max_nesting_level" value="200"/>
    </php>
</phpunit>

' > $MAGENTO2_ENV_WEBROOT/dev/tests/unit/phpunit.xml || exit

echo "
#
# Done. You should now be able to run unit tests
#
"
