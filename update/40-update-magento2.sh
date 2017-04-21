#!/usr/bin/env bash
set -a; . `pwd`/config.env
cd $MAGENTO2_ENV_WEBROOT

# Pull in latest changes using git
git pull
