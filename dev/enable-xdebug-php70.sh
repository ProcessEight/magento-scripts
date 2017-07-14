#!/usr/bin/env bash

echo "Enabling XDebug..."
sudo ln -s /etc/php/7.0/mods-available/xdebug.ini /etc/php/7.0/fpm/conf.d/20-xdebug.ini
sudo ln -s /etc/php/7.0/mods-available/xdebug.ini /etc/php/7.0/cli/conf.d/20-xdebug.ini
sudo service php7.0-fpm restart
/usr/bin/php7.0 -v
