#!/usr/bin/env bash
set -a; . install.env

mkdir -p ~/.composer/

echo "{
   \"http-basic\": {
      \"repo.magento.com\": {
         \"username\": \"$MAGENTO2_PUBLIC_KEY\",
         \"password\": \"$MAGENTO2_PRIVATE_KEY\"
      }
   }
}" > ~/.composer/auth.json