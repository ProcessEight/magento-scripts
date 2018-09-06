#!/usr/bin/env bash

MAGERUN_COMMAND="$@"

#
# Disable Xdebug (if it is enabled)
#
if [[ -f /etc/php/7.1/fpm/conf.d/20-xdebug.ini && -f /etc/php/7.1/cli/conf.d/20-xdebug.ini ]]; then

    # Save Xdebug state
    XDEBUG_SAVED_CONFIG=`echo $XDEBUG_CONFIG`
    unset XDEBUG_CONFIG

    echo "
# Disabling Xdebug...
";
    sudo phpdismod -v 7.1 xdebug
#    /usr/bin/php7.1 -v
fi

# Run n98-magerun2
/var/www/html/n98-magerun2.phar $MAGERUN_COMMAND

#
# Enable Xdebug (if it was enabled)
#
if [[ $XDEBUG_SAVED_CONFIG ]]; then

    # Restore Xdebug state
    export XDEBUG_CONFIG=$XDEBUG_SAVED_CONFIG

    echo "
# Enabling Xdebug...
";
    sudo phpenmod -v 7.1 xdebug
#    /usr/bin/php7.1 -v
fi
