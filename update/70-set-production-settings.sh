#!/usr/bin/env bash
# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/english-braids.localhost.com/scripts
# $ ./update/10-prepare-composer.sh
set -a; . `pwd`/config.env
cd $MAGENTO2_ENV_WEBROOT

# Enable all caches
bin/magento cache:enable

# We skip compilation here because we've already done in the previous step
bin/magento deploy:mode:set production --skip-compilation

# Enable Magento 2 cron
if [[ $MAGENTO2_ENV_ENABLECRON ]];
    then
        "* * * * * /usr/bin/php $MAGENTO2_ENV_WEBROOT/bin/magento cron:run | grep -v "Ran jobs by schedule" >> $MAGENTO2_ENV_WEBROOT/var/log/magento.cron.log" >> /tmp/magento2-crontab
        "* * * * * /usr/bin/php $MAGENTO2_ENV_WEBROOT/update/cron.php >> $MAGENTO2_ENV_WEBROOT/var/log/update.cron.log" /tmp/magento2-crontab
        "* * * * * /usr/bin/php $MAGENTO2_ENV_WEBROOT/bin/magento setup:cron:run >> $MAGENTO2_ENV_WEBROOT/var/log/setup.cron.log" /tmp/magento2-crontab
        crontab /tmp/magento2-crontab
        bin/magento setup:cron:run
fi

#phpdismod xdebug
#phpenmod opcache
#service php7.0-fpm restart