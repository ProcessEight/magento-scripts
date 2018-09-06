#!/usr/bin/env bash

if [[ -f /etc/php/7.2/fpm/conf.d/20-xdebug.ini && -f /etc/php/7.2/cli/conf.d/20-xdebug.ini ]]; then
    echo "
#
# Xdebug is already enabled
#
";
    /usr/bin/php7.2 -v
    exit
fi

echo "
#
# Enabling Xdebug...
#
";
sudo phpenmod -v 7.2 xdebug
/usr/bin/php7.2 -v

echo "
#
# Remember to execute 'export XDEBUG_CONFIG=\"idekey=PHPSTORM\"' if you are debugging from the command line
#
";