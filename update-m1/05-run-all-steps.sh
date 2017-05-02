#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/english-braids.localhost.com/scripts
# $ ./update/10-prepare-composer.sh
set -a; . `pwd`/config-m1.env
cd $MAGENTO1_ENV_WEBROOT

echo "
#
# 1. Prepare composer
#
"

COMPOSER_CMD=$(which composer)
if [[ "" == "$COMPOSER_CMD" ]]
then
    wget https://raw.githubusercontent.com/composer/getcomposer.org/a68fc08d2de42237ae80d77e8dd44488d268e13d/web/installer -O - -q | php -- --quiet --filename=composer --install-dir=/usr/local/bin
fi

mkdir -p ~/.composer/

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

# Composer parallel install plugin
composer global require hirak/prestissimo

# Install the project
# Reads the composer.lock file and installs/updates all dependencies to the specified version
composer install

echo "
#
# Create local.xml (if it doesn't already exist)
#
"

if [[ ! -f $MAGENTO1_ENV_WEBROOT/app/etc/local.xml ]]; then

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

    ./n98-magerun.phar --skip-root-check local-config:generate $MAGENTO1_DB_HOSTNAME $MAGENTO1_DB_USERNAME $MAGENTO1_DB_PASSWORD $MAGENTO1_DB_NAME $MAGENTO1_ENV_SESSIONSAVE $MAGENTO1_ADMIN_FRONTNAME
fi

echo "
#
# 2. Prepare database
#
"

# Prepare database
if [[ $MAGENTO1_DB_BACKUPFIRST == "true" ]]; then
    mysqldump -u root --password=password $MAGENTO1_DB_NAME > $MAGENTO1_DB_NAME.bak.sql
fi

# If database dump exists, then import it
if [[ -f $MAGENTO1_ENV_WEBROOT/var/$MAGENTO1_DB_NAME.bak.sql || $MAGENTO1_ENV_INSTALLSAMPLEDATA == true ]]; then
    mysql -u $MAGENTO1_DB_ROOTUSERNAME $MAGENTO1_DB_ROOTPASSWORD -e "create database $MAGENTO1_DB_NAME"
    mysql -u $MAGENTO1_DB_ROOTUSERNAME $MAGENTO1_DB_ROOTPASSWORD -e "create user '$MAGENTO1_DB_USERNAME'@'$MAGENTO1_DB_HOSTNAME' identified by '$MAGENTO1_DB_PASSWORD'"
    mysql -u $MAGENTO1_DB_ROOTUSERNAME $MAGENTO1_DB_ROOTPASSWORD -e "grant all privileges on $MAGENTO1_DB_NAME.* to '$MAGENTO1_DB_USERNAME'@'$MAGENTO1_DB_HOSTNAME'"
    if [[ $MAGENTO1_ENV_INSTALLSAMPLEDATA == "true" ]]; then
        mysql -u $MAGENTO1_DB_ROOTUSERNAME $MAGENTO1_DB_ROOTPASSWORD $MAGENTO1_DB_NAME < /var/www/html/magento2-deployment/resources/sample-data-$MAGENTO1_ENV_VERSION/magento_sample_data_for_$MAGENTO1_ENV_VERSION.sql
    else
        mysql -u $MAGENTO1_DB_ROOTUSERNAME $MAGENTO1_DB_ROOTPASSWORD $MAGENTO1_DB_NAME < $MAGENTO1_ENV_WEBROOT/var/$MAGENTO1_DB_NAME.bak.sql
    fi
fi

echo "
#
# Install magerun
#
"

# Install n98-magerun
if [[ ! -f n98-magerun.phar ]]; then
    cd $MAGENTO1_ENV_WEBROOT
    wget https://files.magerun.net/n98-magerun.phar && chmod +x ./n98-magerun.phar
fi

echo "
#
# Install magerun-addons
#
"

# Install Kalen Jordans' MageRun Addons (for customer data sterilisation)
if [[ ! -d ~/.n98-magerun/modules/magerun-addons/ ]]; then
    mkdir -p ~/.n98-magerun/modules/
    cd ~/.n98-magerun/modules/
    git clone https://github.com/kalenjordan/magerun-addons.git
    cd $MAGENTO1_ENV_WEBROOT
fi

echo "
#
# Extract media folder backup and move into place (if it exists)
#
"
if [[ -f $MAGENTO1_ENV_WEBROOT/media.bak.tar.gz ]]; then
    tar -xzf media.bak.tar.gz media
fi

echo "
#
# Set permissions and ownership
#
"

# Force correct permissions on files
find var vendor media app/etc -type f -exec chmod u+w {} \;
# Force correct permissions on directories
find var vendor media app/etc -type d -exec chmod u+w {} \;
# Force correct ownership on files
#find var vendor media app/etc -type f -exec chown $MAGENTO1_ENV_CLIUSER:$MAGENTO1_ENV_WEBSERVERGROUP {} \;
# Force correct ownership on directories
#find var vendor media app/etc -type d -exec chown $MAGENTO1_ENV_CLIUSER:$MAGENTO1_ENV_WEBSERVERGROUP {} \;
# Set the sticky bit to ensure that files are generated with the right ownership
find var vendor media app/etc -type d -exec chmod g+s {} \;

# Install frontend tools

# This script assumes the tools needed to compile SASS to CSS are already installed
# If not however, they can be installed using the following commands
# Install Node JS
# sudo apt-get install build-essential libssl-dev
# curl -sL https://raw.githubusercontent.com/creationix/nvm/v0.31.0/install.sh -o install_nvm.sh
# ./install_nvm.sh
# source ~/.profile
# nvm install 7.9.0
# npm install gulp-cli -g
# npm install gulp -D
# Install Yarn
#curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
#echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
#sudo apt-get update && sudo apt-get install yarn
#cd "$MAGENTO1_ENV_WEBROOT/$MAGENTO1_ENV_SKINDIRECTORY"
#rm -rf node_modules
#yarn

echo "
#
# Clear cache
#
"

# Clear cache
./n98-magerun.phar --skip-root-check cache:clean
./n98-magerun.phar --skip-root-check cache:flush

echo "
#
# Generate CSS
#
"

# Generate CSS
cd "$MAGENTO1_ENV_WEBROOT/$MAGENTO1_ENV_SKINDIRECTORY"
gulp build:production --disableMaps --prod
cd $MAGENTO1_ENV_WEBROOT

echo "
#
# Enable maintenance mode
#
"

# Enable maintenance mode
./n98-magerun.phar --skip-root-check sys:maintenance

echo "
#
# Run database upgrades
#
"

# Run database upgrades
./n98-magerun.phar --skip-root-check sys:setup:run

echo "
#
# Disable maintenance mode
#
"

# Disable maintenance mode
./n98-magerun.phar --skip-root-check sys:maintenance

echo "
#
# Enable display_errors
#
"

# Enable display_errors
sed -i -e "s/#ini_set('display_errors', 1);/ini_set('display_errors', 1);/g" index.php

echo "
#
# Create new admin user
#
"

# Create new admin user
./n98-magerun.phar --skip-root-check admin:user:delete $MAGENTO1_ADMIN_USERNAME
./n98-magerun.phar --skip-root-check admin:user:create $MAGENTO1_ADMIN_USERNAME $MAGENTO1_ADMIN_EMAIL $MAGENTO1_ADMIN_PASSWORD $MAGENTO1_ADMIN_FIRSTNAME $MAGENTO1_ADMIN_LASTNAME

echo "
#
# Sterilise customer data
#
"

# Create dummy customer with dummy addresses

# Sterilise customer data
./n98-magerun.phar --skip-root-check customer:anon


echo "
#
# Enable cron
#
"

# Enable cron
php -f $MAGENTO1_ENV_WEBROOT/cron.php
