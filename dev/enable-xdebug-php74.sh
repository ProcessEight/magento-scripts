#!/usr/bin/env bash

if [[ -f /etc/php/7.4/fpm/conf.d/20-xdebug.ini && -f /etc/php/7.4/cli/conf.d/20-xdebug.ini ]]; then
    echo "
#
# Xdebug is already enabled for PHP7.4 FPM and PHP7.4 CLI...
#
";
    /usr/bin/php7.4 -v
    exit
fi

echo "
#
# Enabling Xdebug for PHP7.4 FPM and PHP7.4 CLI...
#
";
sudo ln -s /etc/php/7.4/mods-available/xdebug.ini /etc/php/7.4/fpm/conf.d/20-xdebug.ini
sudo ln -s /etc/php/7.4/mods-available/xdebug.ini /etc/php/7.4/cli/conf.d/20-xdebug.ini
sudo service php7.4-fpm restart
/usr/bin/php7.4 -v

echo "
#
# Remember to execute 'export XDEBUG_CONFIG=\"idekey=PHPSTORM\"' if you are debugging from the command line
#
";
