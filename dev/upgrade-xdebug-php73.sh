#!/usr/bin/env bash

function question() {
  [[ ! "$OPT_F" == "" ]] && return 0
  echo -n "$1 [y/N]: "
  read CONFIRM
  [[ "$CONFIRM" == "y" ]] || [[ "$CONFIRM" == "Y" ]] && return 0
  return 1
}

echo "
#
# Disabling Xdebug...
#
"
sudo rm -f /etc/php/7.3/fpm/conf.d/20-xdebug.ini
sudo rm -f /etc/php/7.3/cli/conf.d/20-xdebug.ini
sudo service php7.3-fpm restart
/usr/bin/php7.3 -v

echo "
#
# Upgrading Xdebug...
#
"

cd /home/zone8/Downloads/ || exit
echo "Removing previous downloads..."
rm -f /home/zone8/Downloads/xdebug-2.9.8.tgz || exit
echo "Downloading latest version for PHP7.3.x..."
wget http://xdebug.org/files/xdebug-2.9.8.tgz || exit
echo "Extracting..."
tar -xvzf xdebug-2.9.8.tgz
if [[ -d /home/zone8/Downloads/xdebug-2.9.8/ ]]; then
  cd /home/zone8/Downloads/xdebug-2.9.8/ || exit
  # Ensure there are no old files hanging around, just waiting to trip us up
  phpize --clean
  phpize7.3 --clean
else
  echo "
#
# Script could not find extracted folder at /home/zone8/Downloads/xdebug-2.9.8/.
# Script cannot continue. Exiting now.
#
"
  exit
fi

echo "
#
# Now the fun begins...
#
# Running phpize7.3
#
"
/usr/bin/phpize7.3 || exit

echo "
#
# Successfully ran /usr/bin/phpize7.3
#
# As part of its output it should show:
#
# Configuring for:
# ...
# Zend Module Api No:      20180731
# Zend Extension Api No:   320180731
#
# If it does not, you are using the wrong phpize.
# Please follow this FAQ entry: https://xdebug.org/docs/faq#custom-phpize
#
"

question "Confirm that the output of phpize7.3 matches that output above:"
if [ $? -eq 0 ]; then
  echo "
#
# You chose...wisely
#
  "
  ./configure --with-php-config=/usr/bin/php-config7.3
  make
  sudo cp /home/zone8/Downloads/xdebug-2.9.8/modules/xdebug.so /usr/lib/php/20180731/xdebug298.so
  sudo nano /etc/php/7.3/mods-available/xdebug.ini

  echo "
  #
  # Enabling Xdebug...
  #
  "
  sudo ln -s /etc/php/7.3/mods-available/xdebug.ini /etc/php/7.3/fpm/conf.d/20-xdebug.ini
  sudo ln -s /etc/php/7.3/mods-available/xdebug.ini /etc/php/7.3/cli/conf.d/20-xdebug.ini
  sudo service php7.3-fpm restart
  /usr/bin/php7.3 -v

  # Clean-up
  rm -rf /home/zone8/Downloads/xdebug-2.9.8/
fi

echo "
#
# If you get the error message: 'Xdebug requires Zend Engine API version XXX. The Zend Engine API version YYY which is installed, is outdated.'
# Then follow the instructions here:
# https://gist.github.com/ProcessEight/000245eac361cbcfeb9daf6de3c1c2e4#error-message-xdebug-requires-zend-engine-api-version-320190902-the-zend-engine-api-version-320180731-which-is-installed-is-outdated
#
"
