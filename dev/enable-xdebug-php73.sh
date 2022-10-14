#!/usr/bin/env bash

if [[ -f /etc/php/7.3/fpm/conf.d/20-xdebug.ini && -f /etc/php/7.3/cli/conf.d/20-xdebug.ini ]]; then
    echo "
#
# Xdebug is already enabled for PHP7.3 FPM and PHP7.3 CLI...
#
";
    /usr/bin/php7.3 -v
    exit
fi

echo "
#
# Enabling Xdebug for PHP7.3 FPM and PHP7.3 CLI...
#
";
sudo ln -s /etc/php/7.3/mods-available/xdebug.ini /etc/php/7.3/fpm/conf.d/20-xdebug.ini
sudo ln -s /etc/php/7.3/mods-available/xdebug.ini /etc/php/7.3/cli/conf.d/20-xdebug.ini
sudo service php7.3-fpm restart
/usr/bin/php7.3 -v

echo "
#
# Remember to execute 'export XDEBUG_CONFIG=\"idekey=PHPSTORM\"' if you are debugging from the command line
#
";
