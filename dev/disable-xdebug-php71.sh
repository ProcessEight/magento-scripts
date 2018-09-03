#!/usr/bin/env bash

if [[ ! -f /etc/php/7.1/fpm/conf.d/20-xdebug.ini && ! -f /etc/php/7.1/cli/conf.d/20-xdebug.ini ]]; then
    echo "
#
# Xdebug is not enabled
#
";
    /usr/bin/php7.1 -v
    exit
fi

echo "
#
# Disabling Xdebug...
#
";
sudo rm -f /etc/php/7.1/fpm/conf.d/20-xdebug.ini
sudo rm -f /etc/php/7.1/cli/conf.d/20-xdebug.ini
sudo service php7.1-fpm restart
/usr/bin/php7.1 -v

echo "
#
# Remember to execute 'unset XDEBUG_CONFIG' if you are debugging from the command line
#
";
