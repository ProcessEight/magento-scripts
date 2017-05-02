#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/english-braids.localhost.com/scripts
# $ ./update/10-prepare-composer.sh
set -a; . `pwd`/config-m2.env

# Composer parallel install plugin
composer global require hirak/prestissimo

mkdir -p $MAGENTO2_ENV_WEBROOT
cd $MAGENTO2_ENV_WEBROOT

echo "# Create a new, blank Magento 2 install"
composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition $MAGENTO2_ENV_WEBROOT $MAGENTO2_ENV_VERSION
composer require snowdog/frontools
composer update

#echo "# Install yarn for gulp"
#curl -sS https://dl.yarnpkg.com/debian/pubkey.gpg | sudo apt-key add -
#echo "deb https://dl.yarnpkg.com/debian/ stable main" | sudo tee /etc/apt/sources.list.d/yarn.list
#sudo apt-get update && sudo apt-get install yarn
cd $MAGENTO2_ENV_WEBROOT/vendor/snowdog/frontools
rm -rf node_modules
yarn install
yarn add gulp-cli
yarn add gulp

cd $MAGENTO2_ENV_WEBROOT
echo "# Make sure we can execute the CLI tool"
chmod u+x bin/magento
echo "# Force correct permissions on files"
find var vendor pub/static pub/media app/etc -type f -exec chmod u+w {} \;
echo "# Force correct permissions on directories"
find var vendor pub/static pub/media app/etc -type d -exec chmod u+w {} \;
echo "# Force correct ownership on files"
find var vendor pub/static pub/media app/etc -type f -exec chown $MAGENTO2_ENV_CLIUSER:$MAGENTO2_ENV_WEBSERVERGROUP {} \;
echo "# Force correct ownership on directories"
find var vendor pub/static pub/media app/etc -type d -exec chown $MAGENTO2_ENV_CLIUSER:$MAGENTO2_ENV_WEBSERVERGROUP {} \;
echo "# Set the sticky bit to ensure that files are generated with the right ownership"
find var vendor pub/static pub/media app/etc -type d -exec chmod g+s {} \;