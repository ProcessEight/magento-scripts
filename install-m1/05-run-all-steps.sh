#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/english-braids.localhost.com/scripts
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
# 1. Prepare composer
#
"

if [[ $MAGENTO1_ENV_VERSION < 1.9.2.4 ]]; then
    export INCHOOPHP7_BRANCH=1.9.2.4-dev;
    export SAMPLEDATA_VERSION=1.9.1.0
elif [[ $MAGENTO1_ENV_VERSION == 1.9.2.4 ]]; then
    export INCHOOPHP7_BRANCH=1.9.2.4-dev;
    export SAMPLEDATA_VERSION=1.9.2.4
else
    export INCHOOPHP7_BRANCH=2.1.0;
    export SAMPLEDATA_VERSION=1.9.2.4
fi

echo "{
    \"name\": \"purenet/$MAGENTO1_DB_NAME\",
    \"description\": \"Magento $MAGENTO1_ENV_EDITION $MAGENTO1_ENV_VERSION\",
    \"extra\": {
        \"magento-root-dir\": \".\"
    },
    \"require\": {
        \"magento-hackathon/magento-composer-installer\": \"~3.0\",
        \"aydin-hassan/magento-core-composer-installer\": \"~1.2\"
    },
    \"require-dev\": {
        \"inchoo/php7\": \"$INCHOOPHP7_BRANCH\"
    }
}" > $MAGENTO1_ENV_WEBROOT/composer.json

cd $MAGENTO1_ENV_WEBROOT

# Install the project
# Reads the composer.lock file and installs/updates all dependencies to the specified version
rm -f composer.lock
composer install

echo "
#
# Searching for (and installing, if necessary) n98-magerun...
#
"

# Search for and install n98-magerun
export MAGERUN_PATH=./n98-magerun.phar
if [[ ! -f ~/n98-magerun.phar ]]; then
    if [[ ! -f /var/www/html/n98-magerun.phar ]]; then
        if [[ ! -f ./n98-magerun.phar ]]; then
            wget https://files.magerun.net/n98-magerun.phar && chmod +x ./n98-magerun.phar
            MAGERUN_PATH=./n98-magerun.phar
        fi
    else
        MAGERUN_PATH=/var/www/html/n98-magerun.phar
    fi
else
    MAGERUN_PATH=~/n98-magerun.phar
fi

# Install Kalen Jordans' MageRun Addons (for customer sterilisation)
if [[ ! -d ~/.n98-magerun/modules/magerun-addons/ ]]; then

    echo "
    #
    # Install magerun-addons
    #
    "
    mkdir -p ~/.n98-magerun/modules/
    cd ~/.n98-magerun/modules/
    git clone git@github.com:kalenjordan/magerun-addons.git
    cd $MAGENTO1_ENV_WEBROOT
fi

if [[ ! -f $MAGENTO1_ENV_WEBROOT/app/etc/local.xml ]]; then

    echo "
#
# Could not find local.xml; Creating a new one now
#
    "

    if [[ ! -f $MAGENTO1_ENV_WEBROOT/app/etc/local.xml.template ]]; then
        echo "<?xml version=\"1.0\"?>
<!--
/**
 * Magento
 *
 * NOTICE OF LICENSE
 *
 * This source file is subject to the Academic Free License (AFL 3.0)
 * that is bundled with this package in the file LICENSE_AFL.txt.
 * It is also available through the world-wide-web at this URL:
 * http://opensource.org/licenses/afl-3.0.php
 * If you did not receive a copy of the license and are unable to
 * obtain it through the world-wide-web, please send an email
 * to license@magentocommerce.com so we can send you a copy immediately.
 *
 * DISCLAIMER
 *
 * Do not edit or add to this file if you wish to upgrade Magento to newer
 * versions in the future. If you wish to customize Magento for your
 * needs please refer to http://www.magentocommerce.com for more information.
 *
 * @category   Mage
 * @package    Mage_Core
 * @copyright  Copyright (c) 2008 Irubin Consulting Inc. DBA Varien (http://www.varien.com)
 * @license    http://opensource.org/licenses/afl-3.0.php  Academic Free License (AFL 3.0)
 */
-->
<config>
    <global>
        <install>
            <date>{{date}}</date>
        </install>
        <crypt>
            <key>{{key}}</key>
        </crypt>
        <disable_local_modules>false</disable_local_modules>
        <resources>
            <db>
                <table_prefix>{{db_prefix}}</table_prefix>
            </db>
            <default_setup>
                <connection>
                    <host>{{db_host}}</host>
                    <username>{{db_user}}</username>
                    <password>{{db_pass}}</password>
                    <dbname>{{db_name}}</dbname>
                    <initStatements>{{db_init_statemants}}</initStatements>
                    <model>{{db_model}}</model>
                    <type>{{db_type}}</type>
                    <pdoType>{{db_pdo_type}}</pdoType>
                    <active>1</active>
                </connection>
            </default_setup>
        </resources>
        <session_save>{{session_save}}</session_save>
    </global>
    <admin>
        <routers>
            <adminhtml>
                <args>
                    <frontName>{{admin_frontname}}</frontName>
                </args>
            </adminhtml>
        </routers>
    </admin>
</config>
" >> $MAGENTO1_ENV_WEBROOT/app/etc/local.xml.template
    fi

    $MAGERUN_PATH local-config:generate $MAGENTO1_DB_HOSTNAME $MAGENTO1_DB_USERNAME $MAGENTO1_DB_PASSWORD $MAGENTO1_DB_NAME $MAGENTO1_ENV_SESSIONSAVE $MAGENTO1_ADMIN_FRONTNAME
fi

if [[ ! -f $MAGENTO1_ENV_WEBROOT/app/etc/config.xml ]]; then

    echo "
#
# Could not find config.xml; Creating a new one now
#
"

echo "<?xml version="1.0"?>
<!--
/**
 * Magento
 *
 * NOTICE OF LICENSE
 *
 * This source file is subject to the Academic Free License (AFL 3.0)
 * that is bundled with this package in the file LICENSE_AFL.txt.
 * It is also available through the world-wide-web at this URL:
 * http://opensource.org/licenses/afl-3.0.php
 * If you did not receive a copy of the license and are unable to
 * obtain it through the world-wide-web, please send an email
 * to license@magento.com so we can send you a copy immediately.
 *
 * DISCLAIMER
 *
 * Do not edit or add to this file if you wish to upgrade Magento to newer
 * versions in the future. If you wish to customize Magento for your
 * needs please refer to http://www.magento.com for more information.
 *
 * @category    Mage
 * @package     Mage_Core
 * @copyright   Copyright (c) 2006-2014 X.commerce, Inc. (http://www.magento.com)
 * @license     http://opensource.org/licenses/afl-3.0.php  Academic Free License (AFL 3.0)
 */
-->
<config>
    <global>
        <install>
            <date/>
        </install>
        <resources>
            <default_setup>
                <connection>
                    <host>localhost</host>
                    <username/>
                    <password/>
                    <dbname>magento</dbname>
                    <model>mysql4</model>
                    <initStatements>SET NAMES utf8</initStatements>
                    <type>pdo_mysql</type>
                    <active>0</active>
                    <persistent>0</persistent>
                </connection>
            </default_setup>
            <default_write>
                <connection>
                    <use>default_setup</use>
                </connection>
            </default_write>
            <default_read>
                <connection>
                    <use>default_setup</use>
                </connection>
            </default_read>
            <core_setup>
                <setup>
                    <module>Mage_Core</module>
                </setup>
                <connection>
                    <use>default_setup</use>
                </connection>
            </core_setup>
            <core_write>
                <connection>
                    <use>default_write</use>
                </connection>
            </core_write>
            <core_read>
                <connection>
                    <use>default_read</use>
                </connection>
            </core_read>
        </resources>
        <resource>
            <connection>
                <types>
                    <pdo_mysql>
                        <adapter>Magento_Db_Adapter_Pdo_Mysql</adapter>
                        <class>Mage_Core_Model_Resource_Type_Db_Pdo_Mysql</class>
                        <compatibleMode>1</compatibleMode>
                    </pdo_mysql>
                </types>
            </connection>
        </resource>
        <models>
            <varien>
                <class>Varien</class>
            </varien>
            <core>
                <class>Mage_Core_Model</class>
                <resourceModel>core_resource</resourceModel>
            </core>
            <core_resource>
                <class>Mage_Core_Model_Resource</class>
                <deprecatedNode>core_mysql4</deprecatedNode>
                <entities>
                    <config_data>
                        <table>core_config_data</table>
                    </config_data>
                    <website>
                        <table>core_website</table>
                    </website>
                    <store>
                        <table>core_store</table>
                    </store>
                    <resource>
                        <table>core_resource</table>
                    </resource>
                    <cache>
                        <table>core_cache</table>
                    </cache>
                    <cache_tag>
                        <table>core_cache_tag</table>
                    </cache_tag>
                    <cache_option>
                        <table>core_cache_option</table>
                    </cache_option>
                </entities>
            </core_resource>
        </models>
    </global>
    <default>
        <system>
            <filesystem>
                <base>{{root_dir}}</base>
                <app>{{root_dir}}/app</app>
                <code>{{app_dir}}/code</code>
                <design>{{app_dir}}/design</design>
                <locale>{{app_dir}}/locale</locale>
                <etc>{{app_dir}}/etc</etc>
                <media>{{root_dir}}/media</media>
                <upload>{{root_dir}}/media/upload</upload>
                <skin>{{root_dir}}/skin</skin>
                <var>{{var_dir}}</var>
                <cache>{{var_dir}}/cache</cache>
                <session>{{var_dir}}/session</session>
                <tmp>{{var_dir}}/tmp</tmp>
                <pear>{{var_dir}}/pear</pear>
                <export>{{var_dir}}/export</export>
            </filesystem>
        </system>
        <general>
            <locale>
                <code>en_US</code>
                <timezone>America/Los_Angeles</timezone>
            </locale>
        </general>
    </default>
    <varien>
        <class>Varien</class>
    </varien>
</config>
" >> $MAGENTO1_ENV_WEBROOT/app/etc/config.xml
fi

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

#echo "
#
# Set permissions and ownership
#
#"
cd $MAGENTO1_ENV_WEBROOT
if [[ ! -d media ]]; then
    mkdir media
fi
# Force correct permissions on files
#find vendor media app/etc -type f -exec chmod u+w {} \;
# Force correct permissions on directories
#find vendor media app/etc -type d -exec chmod u+w {} \;
# Set group id so files are generated with the right permissions and ownership
#find vendor media app/etc -type d -exec chmod g+s {} \;

echo "
#
# Clear cache
#
"
# Clear cache
$MAGERUN_PATH cache:clean
$MAGERUN_PATH cache:flush

if [[ -f $MAGENTO1_ENV_SKINDIRECTORY/gulpfile.js ]]; then

    echo "
    #
    # Generate CSS
    #
    "

    cd $MAGENTO1_ENV_SKINDIRECTORY

    # Generate CSS
    yarn install
    gulp styles --disableMaps --prod
fi

cd $MAGENTO1_ENV_WEBROOT

echo "
#
# Enable maintenance mode
#
"

$MAGERUN_PATH sys:maintenance

echo "
#
# Run database upgrades
#
"

$MAGERUN_PATH sys:setup:run

echo "
#
# Disable maintenance mode
#
"

$MAGERUN_PATH sys:maintenance

# @TODO Enable developer mode (for local environments)

echo "
#
# Enable display_errors
#
"

sed -i -e "s/#ini_set('display_errors', 1);/ini_set('display_errors', 1);/g" index.php

echo "
#
# Create new admin user
#
"

$MAGERUN_PATH admin:user:delete $MAGENTO1_ADMIN_USERNAME
$MAGERUN_PATH admin:user:create $MAGENTO1_ADMIN_USERNAME $MAGENTO1_ADMIN_EMAIL $MAGENTO1_ADMIN_PASSWORD $MAGENTO1_ADMIN_FIRSTNAME $MAGENTO1_ADMIN_LASTNAME

echo "
#
# Sterilising customer data
#
"
$MAGERUN_PATH customer:anon

echo "
#
# Verify Inchoo_PHP7 compatibility module for M1 is configured correctly
#
"
cd $MAGENTO1_ENV_WEBROOT/shell
php -f inchoo_php7_test.php


# @TODO Create dummy customer with dummy addresses

#echo "
##
## Enable cron
##
#"
#php -f $MAGENTO1_ENV_WEBROOT/cron.php
