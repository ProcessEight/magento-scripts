#!/usr/bin/env bash

echo "Disabling XDebug..."
sudo rm -f /etc/php/7.0/fpm/conf.d/20-xdebug.ini
sudo rm -f /etc/php/7.0/cli/conf.d/20-xdebug.ini
sudo service php7.0-fpm restart
/usr/bin/php7.0 -v
