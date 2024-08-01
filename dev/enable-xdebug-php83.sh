#!/usr/bin/env bash

if [[ -f /etc/php/8.3/fpm/conf.d/99-xdebug.ini && -f /etc/php/8.3/cli/conf.d/99-xdebug.ini ]]; then
    echo "
#
# Xdebug is already enabled for PHP8.3 FPM and PHP8.3 CLI...
#
";
    /usr/bin/php8.3 -v
    exit
fi

echo "# Enabling Xdebug for PHP8.3 FPM...";
sudo ln -s /etc/php/8.3/mods-available/xdebug.ini /etc/php/8.3/fpm/conf.d/99-xdebug.ini || exit
echo "# Enabling Xdebug for PHP8.3 CLI...";
sudo ln -s /etc/php/8.3/mods-available/xdebug.ini /etc/php/8.3/cli/conf.d/99-xdebug.ini || exit

echo "# Disabling incompatible module (opcache)...";
sudo rm -f /etc/php/8.3/fpm/conf.d/10-opcache.ini /etc/php/8.3/cli/conf.d/10-opcache.ini || exit
echo "# Disabling incompatible module (blackfire)...";
sudo rm -f /etc/php/8.3/fpm/conf.d/90-blackfire.ini /etc/php/8.3/cli/conf.d/90-blackfire.ini || exit

sudo service php8.3-fpm restart
/usr/bin/php8.3 -v

echo "
#
# Remember to execute 'export XDEBUG_CONFIG=\"idekey=PHPSTORM\"' if you are debugging from the command line
#
";
