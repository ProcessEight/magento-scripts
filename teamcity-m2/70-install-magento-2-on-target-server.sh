#!/usr/bin/env bash

#
# Team City build step configuration
#
# Runner Type:          Command Line
# Step name:            70: Install Magento 2 on target server
# Execute Step:         If all previous steps finished successfully (zero exit code)
# Working directory:    htdocs
# Run:                  Custom script
# Custom script:        See below
#

# TODO: Check if Magento is installed first before running this

ssh administrator@%env.MAGENTO2_ENV_HOSTNAME% << EOF
cd %env.MAGENTO2_ENV_WEBROOT%

echo "Running Magento 2 setup script..."
echo "setup:install --base-url=http://%env.MAGENTO2_ENV_HOSTNAME%/ \
--db-host=%env.MAGENTO2_DB_HOSTNAME% --db-name=%env.MAGENTO2_DB_NAME% --db-user=%env.MAGENTO2_DB_USERNAME% --db-password=%env.MAGENTO2_DB_PASSWORD% \
--admin-firstname=%env.MAGENTO2_ADMIN_FIRSTNAME% --admin-lastname=%env.MAGENTO2_ADMIN_LASTNAME% --admin-email=%env.MAGENTO2_ADMIN_EMAIL% \
--admin-user=%env.MAGENTO2_ADMIN_USERNAME% --admin-password=%env.MAGENTO2_ADMIN_PASSWORD% --language=%env.MAGENTO2_LOCALE_CODE% \
--currency=%env.MAGENTO2_LOCALE_CURRENCY% --timezone=%env.MAGENTO2_LOCALE_TIMEZONE% --use-rewrites=%env.MAGENTO2_ENV_USEREWRITES% --backend-frontname=%env.MAGENTO2_ADMIN_FRONTNAME% --admin-use-security-key=%env.MAGENTO2_ENV_USESECURITYKEY% \
--session-save=%env.MAGENTO2_ENV_SESSIONSAVE% %env.MAGENTO2_INSTALLCOMMAND_CLEANUPDATABASE%"

sudo -u administrator php -f bin/magento setup:install --base-url=http://%env.MAGENTO2_ENV_HOSTNAME%/ \
--db-host=%env.MAGENTO2_DB_HOSTNAME% --db-name=%env.MAGENTO2_DB_NAME% --db-user=%env.MAGENTO2_DB_USERNAME% --db-password=%env.MAGENTO2_DB_PASSWORD% \
--admin-firstname=%env.MAGENTO2_ADMIN_FIRSTNAME% --admin-lastname=%env.MAGENTO2_ADMIN_LASTNAME% --admin-email=%env.MAGENTO2_ADMIN_EMAIL% \
--admin-user=%env.MAGENTO2_ADMIN_USERNAME% --admin-password=%env.MAGENTO2_ADMIN_PASSWORD% --language=%env.MAGENTO2_LOCALE_CODE% \
--currency=%env.MAGENTO2_LOCALE_CURRENCY% --timezone=%env.MAGENTO2_LOCALE_TIMEZONE% --use-rewrites=%env.MAGENTO2_ENV_USEREWRITES% --backend-frontname=%env.MAGENTO2_ADMIN_FRONTNAME% --admin-use-security-key=%env.MAGENTO2_ENV_USESECURITYKEY% \
--session-save=%env.MAGENTO2_ENV_SESSIONSAVE% %env.MAGENTO2_INSTALLCOMMAND_CLEANUPDATABASE%

echo "# Set the group-id bit to ensure that files and directories are generated with the right ownership..."
sudo find var generated pub/static pub/media app/etc -type f -exec chmod g+w {} + &&
sudo find var generated pub/static pub/media app/etc -type d -exec chmod g+ws {} +
echo "# Ensure a clean slate by flushing selected directories..."
sudo rm -rf generated/code/ var/cache/ pub/static/* pub/media/*

sudo -u administrator php -f bin/magento module:enable --all

EOF