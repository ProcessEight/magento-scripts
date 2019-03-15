#!/usr/bin/env bash

if [[ ! -f /etc/php/5.6/fpm/conf.d/20-xdebug.ini && ! -f /etc/php/5.6/cli/conf.d/20-xdebug.ini ]]; then
    echo "
#
# Xdebug is not enabled
#
";
    /usr/bin/php5.6 -v
    exit
fi

echo "
#
# Disabling Xdebug...
#
";
sudo rm -f /etc/php/5.6/fpm/conf.d/20-xdebug.ini
sudo rm -f /etc/php/5.6/cli/conf.d/20-xdebug.ini
sudo service php5.6-fpm restart

echo "
#
# Remember to execute 'unset XDEBUG_CONFIG' if you are debugging from the command line
#
";
