#!/usr/bin/env bash

if [[ -f /etc/php/8.1/fpm/conf.d/99-xdebug.ini && -f /etc/php/8.1/cli/conf.d/99-xdebug.ini ]]; then
    echo "
#
# Xdebug is already enabled for PHP8.1 FPM and PHP8.1 CLI...
#
";
    /usr/bin/php8.1 -v
    exit
fi

echo "
#
# Enabling Xdebug for PHP8.1 FPM and PHP8.1 CLI...
#
";
sudo ln -s /etc/php/8.1/mods-available/xdebug.ini /etc/php/8.1/fpm/conf.d/99-xdebug.ini
sudo ln -s /etc/php/8.1/mods-available/xdebug.ini /etc/php/8.1/cli/conf.d/99-xdebug.ini
sudo service php8.1-fpm restart
/usr/bin/php8.1 -v

echo "
#
# Remember to execute 'export XDEBUG_CONFIG=\"idekey=PHPSTORM\"' if you are debugging from the command line
#
";
