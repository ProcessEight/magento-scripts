#!/usr/bin/env bash

if [[ ! -f /etc/php/8.1/fpm/conf.d/99-xdebug.ini && ! -f /etc/php/8.1/cli/conf.d/99-xdebug.ini ]]; then
    echo "
#
# Xdebug is not enabled for PHP8.1 FPM and PHP8.1 CLI...
#
";
    /usr/bin/php8.1 -v
    exit
fi

echo "
#
# Disabling Xdebug for PHP8.1 FPM and PHP8.1 CLI...
#
";
sudo rm -f /etc/php/8.1/fpm/conf.d/99-xdebug.ini
sudo rm -f /etc/php/8.1/cli/conf.d/99-xdebug.ini

# Just in case there are any legacy ini files
sudo rm -f /etc/php/8.1/cli/conf.d/20-xdebug.ini
sudo rm -f /etc/php/8.1/cli/conf.d/20-xdebug.ini

sudo service php8.1-fpm restart
/usr/bin/php8.1 -v

echo "
#
# Remember to execute 'unset XDEBUG_CONFIG' if you are debugging from the command line
#
";
