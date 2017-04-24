#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/english-braids.localhost.com/scripts
# $ ./update/10-prepare-composer.sh
set -a; . `pwd`/config.env

#echo "Checking for Composer"
COMPOSER_CMD=$(which composer)
if [[ "" == "$COMPOSER_CMD" ]]
then
#    echo "Installing Composer"
    EXPECTED_SIGNATURE=$(wget -q -O - https://composer.github.io/installer.sig)
    php -r "copy('https://getcomposer.org/installer', 'composer-setup.php');"
    ACTUAL_SIGNATURE=$(php -r "echo hash_file('SHA384', 'composer-setup.php');")

    if [ "$EXPECTED_SIGNATURE" != "$ACTUAL_SIGNATURE" ]
    then
        >&2 echo 'ERROR: Invalid Composer installer signature'
        rm composer-setup.php
        exit 1
    fi
    php composer-setup.php --quiet --filename=composer --install-dir=
    RESULT=$?
    rm composer-setup.php
    COMPOSER_CMD=$(which composer)
else
#    echo "Updating Composer"
    $COMPOSER_CMD selfupdate
fi

echo "{
   \"http-basic\": {
      \"repo.magento.com\": {
         \"username\": \"$MAGENTO2_PUBLIC_KEY\",
         \"password\": \"$MAGENTO2_PRIVATE_KEY\"
      }
   }
}" > ~/.composer/auth.json

exit $RESULT
