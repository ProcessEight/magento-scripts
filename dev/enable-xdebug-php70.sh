#!/usr/bin/env bash

if [[ -f /etc/php/7.0/fpm/conf.d/20-xdebug.ini && -f /etc/php/7.0/cli/conf.d/20-xdebug.ini ]]; then
    echo "
#
# Xdebug is already enabled
#
";
    /usr/bin/php7.0 -v
    exit
fi

echo "
#
# Enabling Xdebug...
#
";
sudo ln -s /etc/php/7.0/mods-available/xdebug.ini /etc/php/7.0/fpm/conf.d/20-xdebug.ini
sudo ln -s /etc/php/7.0/mods-available/xdebug.ini /etc/php/7.0/cli/conf.d/20-xdebug.ini
sudo service php7.0-fpm restart
/usr/bin/php7.0 -v
