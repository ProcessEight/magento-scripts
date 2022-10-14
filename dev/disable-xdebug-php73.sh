#!/usr/bin/env bash

if [[ ! -f /etc/php/7.3/fpm/conf.d/20-xdebug.ini && ! -f /etc/php/7.3/cli/conf.d/20-xdebug.ini ]]; then
    echo "
#
# Xdebug is not enabled for PHP7.3 FPM and PHP7.3 CLI...
#
";
    /usr/bin/php7.3 -v
    exit
fi

echo "
#
# Disabling Xdebug for PHP7.3 FPM and PHP7.3 CLI...
#
";
sudo rm -f /etc/php/7.3/fpm/conf.d/20-xdebug.ini
sudo rm -f /etc/php/7.3/cli/conf.d/20-xdebug.ini
sudo service php7.3-fpm restart
/usr/bin/php7.3 -v

echo "
#
# Remember to execute 'unset XDEBUG_CONFIG' if you are debugging from the command line
#
";
