#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/your-project.local/scripts
# $ ./update/10-prepare-composer.sh
set -a; . `pwd`/config-m2.env

COMPOSER_CMD=$(which composer)
if [[ "" == "$COMPOSER_CMD" ]]
then
    wget https://raw.githubusercontent.com/composer/getcomposer.org/a68fc08d2de42237ae80d77e8dd44488d268e13d/web/installer -O - -q | php -- --quiet --filename=composer
fi

mkdir -p ~/.composer/

echo "{
   \"http-basic\": {
      \"repo.magento.com\": {
         \"username\": \"$MAGENTO2_PUBLIC_KEY\",
         \"password\": \"$MAGENTO2_PRIVATE_KEY\"
      }
   }
}" > ~/.composer/auth.json
