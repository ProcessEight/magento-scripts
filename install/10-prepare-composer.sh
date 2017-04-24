#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/english-braids.localhost.com/scripts
# $ ./update/10-prepare-composer.sh
set -a; . `pwd`/config.env

mkdir -p ~/.composer/

echo "{
   \"http-basic\": {
      \"repo.magento.com\": {
         \"username\": \"$MAGENTO2_PUBLIC_KEY\",
         \"password\": \"$MAGENTO2_PRIVATE_KEY\"
      }
   }
}" > ~/.composer/auth.json
