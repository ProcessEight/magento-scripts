#!/usr/bin/env bash

#
# Team City build step configuration
#
# Runner Type:          Command Line
# Step name:            50: Setup backend
# Execute Step:         If all previous steps finished successfully (zero exit code)
# Working directory:    htdocs
# Run:                  Custom script
# Custom script:        See below
#

# Code generation

# These modules are broken (temporary fix)
# TODO: Move module:disable command into an env variable
php -f bin/magento module:disable AudereCommerce_KamarinEcommerceLink AudereCommerce_AccountsIntegration

#echo "Skipping code generation"

# Force clean old files first. Don't rely on Magento 2.
rm -rf var/generation/* var/di/*
if [[ %env.MAGENTO2_ENV_MULTITENANT% == "true" ]];
then
    # For multisites running Magento 2.0.x only
    php -f bin/magento setup:di:compile-multi-tenant
else
    php -f bin/magento setup:di:compile
fi