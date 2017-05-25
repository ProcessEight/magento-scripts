#!/usr/bin/env bash

#
# Team City build step configuration
#
# Runner Type:          Command Line
# Step name:            10: Prepare Composer
# Execute Step:         If all previous steps finished successfully (zero exit code)
# Working directory:    htdocs
# Run:                  Custom script
# Custom script:        See below
#

COMPOSER_CMD=$(which composer)
if [[ "" == "$COMPOSER_CMD" ]]
then
    wget https://raw.githubusercontent.com/composer/getcomposer.org/a68fc08d2de42237ae80d77e8dd44488d268e13d/web/installer -O - -q | php -- --quiet --filename=composer
fi

mkdir -p ~/.composer/

echo "{
   \"http-basic\": {
      \"repo.magento.com\": {
         \"username\": \"%env.MAGENTO2_PUBLIC_KEY%\",
         \"password\": \"%env.MAGENTO2_PRIVATE_KEY%\"
      }
   }
}" > ~/.composer/auth.json