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
rm -f $MAGENTO2_ENV_WEBROOT/dev/tests/integration/etc/install-config-mysql.php
rm -f $MAGENTO2_ENV_WEBROOT/dev/tests/integration/phpunit.xml

echo "
#
# Setup $MAGENTO2_ENV_WEBROOT/dev/tests/integration/phpunit.xml
#
"

echo '<?xml version="1.0" encoding="UTF-8"?>
<phpunit xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"
         xsi:noNamespaceSchemaLocation="https://schema.phpunit.de/9.3/phpunit.xsd"
         colors="true"
         columns="max"
         beStrictAboutTestsThatDoNotTestAnything="false"
         bootstrap="./framework/bootstrap.php"
         stderr="true"
         testSuiteLoaderClass="Magento\TestFramework\SuiteLoader"
         testSuiteLoaderFile="framework/Magento/TestFramework/SuiteLoader.php">
    <!-- Test suites definition -->
    <testsuites>
        <testsuite name="Magento Integration Tests">
            <file>testsuite/Magento/IntegrationTest.php</file>
        </testsuite>
        <!-- Memory tests run first to prevent influence of other tests on accuracy of memory measurements -->
        <testsuite name="Memory Usage Tests">
            <file>testsuite/Magento/MemoryUsageTest.php</file>
        </testsuite>
        <testsuite name="Magento Integration Tests Real Suite">
            <directory>testsuite</directory>
            <directory>../../../app/code/*/*/Test/Integration</directory>
            <exclude>testsuite/Magento/MemoryUsageTest.php</exclude>
            <exclude>testsuite/Magento/IntegrationTest.php</exclude>
        </testsuite>
        <testsuite name="'$MAGENTO2_ENV_HOSTNAME' Integration Tests">
            <directory>../../../app/code/*/*/Test/Integration</directory>
        </testsuite>
    </testsuites>
    <!-- PHP INI settings and constants definition -->
    <php>
        <includePath>.</includePath>
        <includePath>testsuite</includePath>
        <ini name="date.timezone" value="'$MAGENTO2_LOCALE_TIMEZONE'"/>
        <ini name="xdebug.max_nesting_level" value="200"/>
        <!-- Local XML configuration file (''.dist'' extension will be added, if the specified file doesn''t exist) -->
        <const name="TESTS_INSTALL_CONFIG_FILE" value="etc/install-config-mysql.php"/>
        <!-- Local XML post installation configuration file (''.dist'' extension will be added, if the specified file doesn''t exist) -->
        <const name="TESTS_POST_INSTALL_SETUP_COMMAND_CONFIG_FILE" value="etc/post-install-setup-command-config.php"/>
        <!-- Local XML configuration file (''.dist'' extension will be added, if the specified file doesn''t exist) -->
        <const name="TESTS_GLOBAL_CONFIG_FILE" value="etc/config-global.php"/>
        <!-- Semicolon-separated ''glob'' patterns, that match global XML configuration files -->
        <const name="TESTS_GLOBAL_CONFIG_DIR" value="../../../app/etc"/>
        <!-- Whether to cleanup the application before running tests or not -->
        <const name="TESTS_CLEANUP" value="enabled"/>
        <!-- Memory usage and estimated leaks thresholds -->
        <!--<const name="TESTS_MEM_USAGE_LIMIT" value="1024M"/>-->
        <const name="TESTS_MEM_LEAK_LIMIT" value=""/>
        <!-- Whether to output all CLI commands executed by the bootstrap and tests -->
        <const name="TESTS_EXTRA_VERBOSE_LOG" value="1"/>
        <!-- Magento mode for tests execution. Possible values are "default", "developer" and "production". -->
        <const name="TESTS_MAGENTO_MODE" value="developer"/>
        <!-- Minimum error log level to listen for. Possible values: -1 ignore all errors, and level constants form http://tools.ietf.org/html/rfc5424 standard -->
        <const name="TESTS_ERROR_LOG_LISTENER_LEVEL" value="-1"/>
        <!-- Connection parameters for RabbitMQ tests -->
        <!--<const name="RABBITMQ_MANAGEMENT_PROTOCOL" value="https"/>-->
        <!--<const name="RABBITMQ_MANAGEMENT_PORT" value="15672"/>-->
        <!--<const name="RABBITMQ_VIRTUALHOST" value="/"/>-->
        <!--<const name="TESTS_PARALLEL_RUN" value="1"/>-->
        <const name="USE_OVERRIDE_CONFIG" value="enabled"/>
    </php>
</phpunit>

' > $MAGENTO2_ENV_WEBROOT/dev/tests/integration/phpunit.xml || exit

echo "
#
# Setup $MAGENTO2_ENV_WEBROOT/dev/tests/integration/etc/install-config-mysql.php
#
"

echo "<?php

return [
    'db-host' => '$MAGENTO2_INTEGRATION_TESTS_DB_HOSTNAME',
    'db-user' => '$MAGENTO2_INTEGRATION_TESTS_DB_USERNAME',
    'db-password' => '$MAGENTO2_INTEGRATION_TESTS_DB_PASSWORD',
    'db-name' => '$MAGENTO2_INTEGRATION_TESTS_DB_NAME',
    'db-prefix' => '',
    'backend-frontname' => '$MAGENTO2_ADMIN_FRONTNAME',
    'search-engine' => 'opensearch',
    'opensearch-host' => 'localhost',
    'opensearch-port' => 9200,
    'admin-user' => '$MAGENTO2_ADMIN_USERNAME',
    'admin-password' => '$MAGENTO2_ADMIN_PASSWORD',
    'admin-email' => '$MAGENTO2_ADMIN_EMAIL',
    'admin-firstname' => '$MAGENTO2_ADMIN_FIRSTNAME',
    'admin-lastname' => '$MAGENTO2_ADMIN_LASTNAME',
    'amqp-host' => 'localhost',
    'amqp-port' => '5672',
    'amqp-user' => 'guest',
    'amqp-password' => 'guest',
    'consumers-wait-for-messages' => '0',
];

" > $MAGENTO2_ENV_WEBROOT/dev/tests/integration/etc/install-config-mysql.php || exit

echo "
#
# Setup integration tests database
#
"

mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "DROP DATABASE IF EXISTS $MAGENTO2_INTEGRATION_TESTS_DB_NAME; CREATE DATABASE $MAGENTO2_INTEGRATION_TESTS_DB_NAME"

# Check if the user exists and if not, create a dummy user with a harmless privilege which we'll drop in the next step
# This prevents MySQL from issuing an error if the user does not exist
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "GRANT USAGE ON *.* TO '$MAGENTO2_INTEGRATION_TESTS_DB_USERNAME'@'$MAGENTO2_INTEGRATION_TESTS_DB_HOSTNAME' IDENTIFIED BY '$MAGENTO2_INTEGRATION_TESTS_DB_PASSWORD'"
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "DROP USER '$MAGENTO2_INTEGRATION_TESTS_DB_USERNAME'@'$MAGENTO2_INTEGRATION_TESTS_DB_HOSTNAME'"
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "CREATE USER '$MAGENTO2_INTEGRATION_TESTS_DB_USERNAME'@'$MAGENTO2_INTEGRATION_TESTS_DB_HOSTNAME' IDENTIFIED BY '$MAGENTO2_INTEGRATION_TESTS_DB_PASSWORD'"
mysql $MAGENTO2_DB_ROOTUSERNAME $MAGENTO2_DB_ROOTPASSWORD -e "GRANT ALL PRIVILEGES ON $MAGENTO2_INTEGRATION_TESTS_DB_NAME.* TO '$MAGENTO2_INTEGRATION_TESTS_DB_USERNAME'@'$MAGENTO2_INTEGRATION_TESTS_DB_HOSTNAME'"

echo "
#
# Done. You should now be able to run integration tests
#
"
