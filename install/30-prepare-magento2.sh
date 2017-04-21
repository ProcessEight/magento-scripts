#!/usr/bin/env bash
set -a; . `pwd`/config.env

mkdir -p $MAGENTO2_ENV_WEBROOT
cd $MAGENTO2_ENV_WEBROOT
composer create-project --repository-url=https://repo.magento.com/ magento/project-community-edition $MAGENTO2_ENV_WEBROOT $MAGENTO2_ENV_VERSION
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