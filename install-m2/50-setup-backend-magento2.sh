#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/your-project.local/scripts
# $ ./update/10-prepare-composer.sh
set -a; . `pwd`/config-m2.env
cd $MAGENTO2_ENV_WEBROOT

# Code generation

if [[ $MAGENTO2_ENV_MULTITENANT == true ]];
then
    # For multisites running Magento 2.0.x only
    bin/magento setup:di:compile-multi-tenant
else
    bin/magento setup:di:compile
fi
# Now that we've generated all the possible classes that could exist,
# generate an optimised composer class map that supports faster autoloading
$MAGENTO2_ENV_COMPOSERCOMMAND dump-autoload -o
