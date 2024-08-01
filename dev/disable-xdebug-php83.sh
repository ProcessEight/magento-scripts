#!/usr/bin/env bash

if [[ ! -f /etc/php/8.3/fpm/conf.d/99-xdebug.ini && ! -f /etc/php/8.3/cli/conf.d/99-xdebug.ini ]]; then
    echo "
#
# Xdebug is not enabled for PHP8.3 FPM and PHP8.3 CLI...
#
";
    /usr/bin/php8.3 -v
    exit
fi

echo "# Disabling Xdebug for PHP8.3 FPM...";
sudo rm -f /etc/php/8.3/fpm/conf.d/20-xdebug.ini
sudo rm -f /etc/php/8.3/fpm/conf.d/99-xdebug.ini
echo "# Disabling Xdebug for PHP8.3 CLI...";
sudo rm -f /etc/php/8.3/cli/conf.d/20-xdebug.ini
sudo rm -f /etc/php/8.3/cli/conf.d/99-xdebug.ini

echo "# Enabling opcache for PHP8.3 FPM but not CLI..."
# Delete any existing symlinks, just in case there are any legacy ini files
sudo rm -f /etc/php/8.3/cli/conf.d/10-opcache.ini /etc/php/8.3/fpm/conf.d/10-opcache.ini
sudo ln -s /etc/php/8.3/mods-available/opcache.ini /etc/php/8.3/fpm/conf.d/10-opcache.ini || exit

if [[ -f /etc/php/8.3/mods-available/blackfire.ini ]]; then
  # Delete any existing symlinks, just in case there are any legacy ini files
  sudo rm -f /etc/php/8.3/cli/conf.d/90-blackfire.ini /etc/php/8.3/fpm/conf.d/90-blackfire.ini

  echo "# Enabling blackfire for PHP8.3 FPM..."
  sudo ln -s /etc/php/8.3/mods-available/blackfire.ini /etc/php/8.3/fpm/conf.d/90-blackfire.ini || exit
  echo "# Enabling blackfire for PHP8.3 CLI..."
  sudo ln -s /etc/php/8.3/mods-available/blackfire.ini /etc/php/8.3/fpm/conf.d/90-blackfire.ini || exit
fi

sudo service php8.3-fpm restart
/usr/bin/php8.3 -v

echo "
#
# Remember to execute 'unset XDEBUG_CONFIG' if you are debugging from the command line
#
";
