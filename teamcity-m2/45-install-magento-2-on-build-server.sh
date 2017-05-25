#!/usr/bin/env bash

#
# Team City build step configuration
#
# Runner Type:          Command Line
# Step name:            45: Install Magento 2 on build server
# Execute Step:         If all previous steps finished successfully (zero exit code)
# Working directory:    htdocs
# Run:                  Custom script
# Custom script:        See below
#

# TODO: Check if Magento is installed first before running this

echo "Installing Magento 2 on build server..."
echo "setup:install --base-url=%env.MAGENTO2_ENV_HOSTNAME% \
--db-host=%env.MAGENTO2_DB_HOSTNAME% --db-name=%env.MAGENTO2_DB_NAME% --db-user=%env.MAGENTO2_DB_USERNAME% --db-password=%env.MAGENTO2_DB_PASSWORD% \
--admin-firstname=%env.MAGENTO2_ADMIN_FIRSTNAME% --admin-lastname=%env.MAGENTO2_ADMIN_LASTNAME% --admin-email=%env.MAGENTO2_ADMIN_EMAIL% \
--admin-user=%env.MAGENTO2_ADMIN_USERNAME% --admin-password=%env.MAGENTO2_ADMIN_PASSWORD% --language=%env.MAGENTO2_LOCALE_CODE% \
--currency=%env.MAGENTO2_LOCALE_CURRENCY% --timezone=%env.MAGENTO2_LOCALE_TIMEZONE% --use-rewrites=%env.MAGENTO2_CONFIG_REWRITES% --backend-frontname=%env.MAGENTO2_ADMIN_FRONTNAME% --admin-use-security-key=%env.MAGENTO2_CONFIG_SECURITYKEY% \
--session-save=%env.MAGENTO2_ENV_SESSIONSAVE% --cleanup-database"

php -f bin/magento setup:install --base-url=http://%env.MAGENTO2_ENV_HOSTNAME%/ \
--db-host=%env.MAGENTO2_DB_HOSTNAME% --db-name=%env.MAGENTO2_DB_NAME% --db-user=%env.MAGENTO2_DB_USERNAME% --db-password=%env.MAGENTO2_DB_PASSWORD% \
--admin-firstname=%env.MAGENTO2_ADMIN_FIRSTNAME% --admin-lastname=%env.MAGENTO2_ADMIN_LASTNAME% --admin-email=%env.MAGENTO2_ADMIN_EMAIL% \
--admin-user=%env.MAGENTO2_ADMIN_USERNAME% --admin-password=%env.MAGENTO2_ADMIN_PASSWORD% --language=%env.MAGENTO2_LOCALE_CODE% \
--currency=%env.MAGENTO2_LOCALE_CURRENCY% --timezone=%env.MAGENTO2_LOCALE_TIMEZONE% --use-rewrites=%env.MAGENTO2_CONFIG_REWRITES% --backend-frontname=%env.MAGENTO2_ADMIN_FRONTNAME% --admin-use-security-key=%env.MAGENTO2_CONFIG_SECURITYKEY% \
--session-save=%env.MAGENTO2_ENV_SESSIONSAVE% --cleanup-database