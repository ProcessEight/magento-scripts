#!/usr/bin/env bash
set -a; . /var/www/html/deploytest2.localhost.com/config.env

echo "
#
# 1. Prepare composer
#
"
source ./install/10-prepare-composer.sh

echo "
#
# 2. Prepare database
#
"
source ./install/20-prepare-database.sh

echo "
#
# 3. Prepare Magento 2
#
"
source ./install/30-prepare-magento2.sh

echo "
#
# 4. Install Magento 2
#
"
source ./install/40-install-magento2.sh

echo "
#
# 5. Setup Magento 2
#
"
source ./install/50-setup-magento2.sh

echo "
#
# 6. Run database changes
#
"
source ./install/60-setup-database.sh

echo "
#
# 7. Set production settings
#
"
source ./install/70-set-production-settings.sh