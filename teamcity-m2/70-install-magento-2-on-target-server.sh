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
--currency=%env.MAGENTO2_LOCALE_CURRENCY% --timezone=%env.MAGENTO2_LOCALE_TIMEZONE% --use-rewrites=%env.MAGENTO2_ENV_REWRITES% --backend-frontname=%env.MAGENTO2_ADMIN_FRONTNAME% --admin-use-security-key=%env.MAGENTO2_ENV_SECURITYKEY% \
--session-save=%env.MAGENTO2_ENV_SESSIONSAVE% %env.MAGENTO2_INSTALLCOMMAND_CLEANUPDATABASE%"

sudo -u administrator php -f bin/magento setup:install --base-url=http://%env.MAGENTO2_ENV_HOSTNAME%/ \
--db-host=%env.MAGENTO2_DB_HOSTNAME% --db-name=%env.MAGENTO2_DB_NAME% --db-user=%env.MAGENTO2_DB_USERNAME% --db-password=%env.MAGENTO2_DB_PASSWORD% \
--admin-firstname=%env.MAGENTO2_ADMIN_FIRSTNAME% --admin-lastname=%env.MAGENTO2_ADMIN_LASTNAME% --admin-email=%env.MAGENTO2_ADMIN_EMAIL% \
--admin-user=%env.MAGENTO2_ADMIN_USERNAME% --admin-password=%env.MAGENTO2_ADMIN_PASSWORD% --language=%env.MAGENTO2_LOCALE_CODE% \
--currency=%env.MAGENTO2_LOCALE_CURRENCY% --timezone=%env.MAGENTO2_LOCALE_TIMEZONE% --use-rewrites=%env.MAGENTO2_ENV_REWRITES% --backend-frontname=%env.MAGENTO2_ADMIN_FRONTNAME% --admin-use-security-key=%env.MAGENTO2_ENV_SECURITYKEY% \
--session-save=%env.MAGENTO2_ENV_SESSIONSAVE% %env.MAGENTO2_INSTALLCOMMAND_CLEANUPDATABASE%

echo "# Force correct permissions on files"
sudo find var vendor pub/static pub/media app/etc -type f -exec chmod u+w {} \;
echo "# Force correct permissions on directories"
sudo find var vendor pub/static pub/media app/etc -type d -exec chmod u+w {} \;
echo "# Force correct ownership on files"
sudo find var vendor pub/static pub/media app/etc -type f -exec chown %env.MAGENTO2_ENV_CLIUSER%:%env.MAGENTO2_ENV_WEBSERVERGROUP% {} \;
echo "# Force correct ownership on directories"
sudo find var vendor pub/static pub/media app/etc -type d -exec chown %env.MAGENTO2_ENV_CLIUSER%:%env.MAGENTO2_ENV_WEBSERVERGROUP% {} \;
echo "# Set the set-group-uid bit to ensure that directories are generated with the right ownership"
sudo find var pub/static pub/media app/etc -type d -exec chmod g+s {} \;

sudo -u administrator php -f bin/magento module:enable --all

EOF