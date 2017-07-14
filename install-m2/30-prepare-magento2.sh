#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/english-braids.localhost.com/scripts
# $ ./update/10-prepare-composer.sh
set -a; . `pwd`/config-m2.env
cd $MAGENTO2_ENV_WEBROOT

if [[ ! -d $MAGENTO2_ENV_WEBROOT ]]; then
    mkdir -p $MAGENTO2_ENV_WEBROOT

    echo "# Create a new, blank Magento 2 install"
    composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition $MAGENTO2_ENV_WEBROOT $MAGENTO2_ENV_VERSION
fi;
composer require snowdog/frontools ^1.4

cd $MAGENTO2_ENV_WEBROOT
echo "# Make sure we can execute the CLI tool"
chmod u+x bin/magento
echo "# Force correct permissions on files"
sudo find var vendor pub/static pub/media app/etc -type f -exec chmod 775 {} \;
echo "# Force correct permissions on directories"
sudo find var vendor pub/static pub/media app/etc -type d -exec chmod 665 {} \;
echo "# Force correct ownership on files"
sudo find var vendor pub/static pub/media app/etc -type f -exec chown $MAGENTO2_ENV_CLIUSER:$MAGENTO2_ENV_WEBSERVERGROUP {} \;
echo "# Force correct ownership on directories"
sudo find var vendor pub/static pub/media app/etc -type d -exec chown $MAGENTO2_ENV_CLIUSER:$MAGENTO2_ENV_WEBSERVERGROUP {} \;
echo "# Set the sticky bit to ensure that files are generated with the right ownership"
sudo find var vendor pub/static pub/media app/etc -type d -exec chmod g+s {} \;
