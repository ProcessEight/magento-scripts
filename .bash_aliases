#
# PHP
#
alias php71='/usr/bin/php7.1 -v && /usr/bin/php7.1'
alias php72='/usr/bin/php7.2 -v && /usr/bin/php7.2'
alias php73='/usr/bin/php7.3 -v && /usr/bin/php7.3'
alias php74='/usr/bin/php7.4 -v && /usr/bin/php7.4'
alias php8='/usr/bin/php8.0 -v && /usr/bin/php8.0'
alias php80='/usr/bin/php8.0 -v && /usr/bin/php8.0'
alias php81='/usr/bin/php8.1 -v && /usr/bin/php8.1'
alias php82='/usr/bin/php8.2 -v && /usr/bin/php8.2'

#
# PHP Tools
#
alias phpcs='~/.composer/vendor/bin/phpcs '
#alias composer='/usr/bin/php7.3 -v && /usr/bin/php7.3 -n -d extension=bcmath.so -d extension=ctype.so -d extension=curl.so -d extension=dom.so -d extension=gd.so -d extension=gettext.so -d extension=iconv.so -d extension=intl.so -d extension=json.so -d extension=mbstring.so -d extension=mysqlnd.so -d extension=pdo.so -d extension=pdo_mysql.so -d extension=phar.so -d extension=posix.so -d extension=readline.so -d extension=simplexml.so -d extension=soap.so -d extension=sockets.so -d extension=sysvmsg.so -d extension=sysvsem.so -d extension=sysvshm.so -d extension=tokenizer.so -d extension=xml.so -d extension=xmlwriter.so -d extension=xsl.so -d extension=zip.so /usr/local/bin/composer --ansi '
alias composer1='/usr/local/bin/composer --ansi '
alias composer2='/usr/local/bin/composer2 --ansi '
alias rbm='robo --load-from /var/www/html/magento-scripts/robo/ '
alias dpd='php -n ~/tools/dephpend '
alias xdephp71='/var/www/html/magento-scripts/dev/enable-xdebug-php71.sh'
alias xddphp71='/var/www/html/magento-scripts/dev/disable-xdebug-php71.sh'
alias xdephp72='/var/www/html/magento-scripts/dev/enable-xdebug-php72.sh'
alias xddphp72='/var/www/html/magento-scripts/dev/disable-xdebug-php72.sh'
alias xdephp73='/var/www/html/magento-scripts/dev/enable-xdebug-php73.sh'
alias xddphp73='/var/www/html/magento-scripts/dev/disable-xdebug-php73.sh'
alias xdephp74='/var/www/html/magento-scripts/dev/enable-xdebug-php74.sh'
alias xddphp74='/var/www/html/magento-scripts/dev/disable-xdebug-php74.sh'
alias xdephp81='/var/www/html/magento-scripts/dev/enable-xdebug-php81.sh'
alias xddphp81='/var/www/html/magento-scripts/dev/disable-xdebug-php81.sh'

#
# Projects
#
alias wwwd='cd /var/www/html/'
alias m2rnd='cd /var/www/html/m2/research/'
alias wat='cd /var/www/html/watson/watson-safari/'

#
# Magento 1
#
alias mr='/usr/bin/php7.3 /var/www/html/n98-magerun.phar --ansi'
alias mr1='/usr/bin/php7.1 /var/www/html/n98-magerun.phar --ansi'

#
# Magento 2
#
alias wwwdata='sudo su - www-data -s /bin/bash '

#
# We Are Magneto
#

# Algeos
alias al='cd /var/www/html/wearemagneto/projects/algeos/html '
alias almr='cd /var/www/html/wearemagneto/projects/algeos/html && mr72'
alias alphp='cd /var/www/html/wearemagneto/projects/algeos/html && /usr/bin/php7.2 -v && /usr/bin/php7.2'
alias alreset='xddphp72 && cd ../scripts/ && ./dev/reset-everything.sh && cd ../html'
alias alxe='cd /var/www/html/wearemagneto/projects/algeos/html && /var/www/html/magento-scripts/dev/enable-xdebug-php72.sh'
alias alxd='cd /var/www/html/wearemagneto/projects/algeos/html && /var/www/html/magento-scripts/dev/disable-xdebug-php72.sh'
alias almy='cd /var/www/html/wearemagneto/projects/algeos/html && /usr/bin/mycli -u root --password=$MYSQL_PASSWORD --database=wam_algeos'
alias alcc='/home/zone8/.composer/vendor/bin/cache-clean.js --watch --directory /var/www/html/wearemagneto/projects/algeos/html/'

# Barker & Stonehouse
alias bs='cd /var/www/html/wearemagneto/projects/barker-and-stonehouse/html '
alias bsmr='cd /var/www/html/wearemagneto/projects/barker-and-stonehouse/html && /usr/bin/php7.3 -v && /usr/bin/php7.3 /var/www/html/n98-magerun2.phar --ansi'
alias bsphp='cd /var/www/html/wearemagneto/projects/barker-and-stonehouse/html && /usr/bin/php7.3 -v && /usr/bin/php7.3'
alias bsreset='bsxd && cd /var/www/html/wearemagneto/projects/barker-and-stonehouse/scripts/ && ./dev/reset-everything.sh && cd ../html'
alias bsxe='cd /var/www/html/wearemagneto/projects/barker-and-stonehouse/html && /var/www/html/magento-scripts/dev/enable-xdebug-php73.sh'
alias bsxd='cd /var/www/html/wearemagneto/projects/barker-and-stonehouse/html && /var/www/html/magento-scripts/dev/disable-xdebug-php73.sh'
alias bsmy='cd /var/www/html/wearemagneto/projects/barker-and-stonehouse/html && /usr/bin/mycli -u root --password=$MYSQL_PASSWORD --local-infile=1 --database=wam_barker_fromlive'
alias bscc='/home/zone8/.composer/vendor/bin/cache-clean.js --watch --directory /var/www/html/wearemagneto/projects/barker-and-stonehouse/html/'

# FB Forme Bikes
alias fb='cd /var/www/html/wearemagneto/projects/fb-forme-bikes/html '
alias fbmr='cd /var/www/html/wearemagneto/projects/fb-forme-bikes/html && /usr/bin/php7.4 -v && /usr/bin/php7.4 /var/www/html/n98-magerun2.phar --ansi'
alias fbphp='cd /var/www/html/wearemagneto/projects/fb-forme-bikes/html && /usr/bin/php7.4 -v && /usr/bin/php7.4'
alias fbreset='xddphp74 && cd /var/www/html/wearemagneto/projects/fb-forme-bikes/scripts/ && ./dev/reset-everything.sh && cd /var/www/html/wearemagneto/projects/fb-forme-bikes/html'
alias fbxe='cd /var/www/html/wearemagneto/projects/fb-forme-bikes/html && /var/www/html/magento-scripts/dev/enable-xdebug-php74.sh'
alias fbxd='cd /var/www/html/wearemagneto/projects/fb-forme-bikes/html && /var/www/html/magento-scripts/dev/disable-xdebug-php74.sh'
alias fbmy='cd /var/www/html/wearemagneto/projects/fb-forme-bikes/html && /usr/bin/mycli -u root --password=$MYSQL_PASSWORD --local-infile=1 --database=wam_formebikes'
alias fbcc='/home/zone8/.composer/vendor/bin/cache-clean.js --watch --directory /var/www/html/wearemagneto/projects/fb-forme-bikes/html/'

# Moore Large
alias ml='cd /var/www/html/wearemagneto/projects/moore-large-co/html '
alias mlmr='cd /var/www/html/wearemagneto/projects/moore-large-co/html && /usr/bin/php7.1 -v && /usr/bin/php7.1 /var/www/html/n98-magerun2.phar --ansi'
alias mlphp='cd /var/www/html/wearemagneto/projects/moore-large-co/html && /usr/bin/php7.1 -v && /usr/bin/php7.1'
alias mlreset='xddphp71 && cd /var/www/html/wearemagneto/projects/moore-large-co/scripts/ && ./dev/reset-everything.sh && cd /var/www/html/wearemagneto/projects/moore-large-co/html'
alias mlxe='cd /var/www/html/wearemagneto/projects/moore-large-co/html && /var/www/html/magento-scripts/dev/enable-xdebug-php71.sh'
alias mlxd='cd /var/www/html/wearemagneto/projects/moore-large-co/html && /var/www/html/magento-scripts/dev/disable-xdebug-php71.sh'
alias mlmy='cd /var/www/html/wearemagneto/projects/moore-large-co/html && /usr/bin/mycli -u root --password=$MYSQL_PASSWORD --local-infile=1 --database=wam_moorelargeco'
alias mlcc='/home/zone8/.composer/vendor/bin/cache-clean.js --watch --directory /var/www/html/wearemagneto/projects/moore-large-co/html/'

# Moore Large New Build
alias mlnb='cd /var/www/html/wearemagneto/projects/mlnb/html '
alias mlnbmr='cd /var/www/html/wearemagneto/projects/mlnb/html && /usr/bin/php7.4 -v && /usr/bin/php7.4 /var/www/html/n98-magerun2.phar --ansi'
alias mlnbphp='cd /var/www/html/wearemagneto/projects/mlnb/html && /usr/bin/php7.4 -v && /usr/bin/php7.4'
alias mlnbreset='xddphp74 && cd /var/www/html/wearemagneto/projects/mlnb/scripts/ && ./dev/reset-everything.sh && cd /var/www/html/wearemagneto/projects/mlnb/html'
alias mlnbxe='cd /var/www/html/wearemagneto/projects/mlnb/html && /var/www/html/magento-scripts/dev/enable-xdebug-php74.sh'
alias mlnbxd='cd /var/www/html/wearemagneto/projects/mlnb/html && /var/www/html/magento-scripts/dev/disable-xdebug-php74.sh'
alias mlnbmy='cd /var/www/html/wearemagneto/projects/mlnb/html && /usr/bin/mycli -u root --password=$MYSQL_PASSWORD --local-infile=1 --database=wam_mlnb'
alias mlnbcc='/home/zone8/.composer/vendor/bin/cache-clean.js --watch --directory /var/www/html/wearemagneto/projects/mlnb/html/'

# UFH Underfloor Heating
alias ufh='cd /var/www/html/wearemagneto/projects/ufh/html '
alias ufhmr='cd /var/www/html/wearemagneto/projects/ufh/html && mr73'
alias ufhphp='cd /var/www/html/wearemagneto/projects/ufh/html && /usr/bin/php7.3 -v && /usr/bin/php7.3'
#alias ufhreset='xddphp73 && cd ../scripts/ && ./dev/reset-everything.sh && cd ../html'
alias ufhreset='cd ../scripts/ && ./dev/reset-everything.sh && cd ../html'
#alias ufhxe='cd /var/www/html/wearemagneto/projects/ufh/html && /var/www/html/magento-scripts/dev/enable-xdebug-php73.sh'
#alias ufhxd='cd /var/www/html/wearemagneto/projects/ufh/html && /var/www/html/magento-scripts/dev/disable-xdebug-php73.sh'
alias ufhmy='cd /var/www/html/wearemagneto/projects/ufh/html && /usr/bin/mycli -u root --password=$MYSQL_PASSWORD --database=wam_ufh'
alias ufhcc='/home/zone8/.composer/vendor/bin/cache-clean.js --watch --directory /var/www/html/wearemagneto/projects/ufh/html/'

# Verona Stone
alias ver='cd /var/www/html/wearemagneto/projects/verona-group/html '
alias vermr='cd /var/www/html/wearemagneto/projects/verona-group/html && /usr/bin/php7.2 -v && /usr/bin/php7.2 /var/www/html/n98-magerun2.phar --ansi'
alias verphp='cd /var/www/html/wearemagneto/projects/verona-group/html && /usr/bin/php7.2 -v && /usr/bin/php7.2'
alias verreset='xddphp72 && cd /var/www/html/wearemagneto/projects/verona-group/scripts/ && ./dev/reset-everything.sh && cd ../html'
alias verxe='cd /var/www/html/wearemagneto/projects/verona-group/html && /var/www/html/magento-scripts/dev/enable-xdebug-php72.sh'
alias verxd='cd /var/www/html/wearemagneto/projects/verona-group/html && /var/www/html/magento-scripts/dev/disable-xdebug-php72.sh'
alias vermy='cd /var/www/html/wearemagneto/projects/verona-group/html && /usr/bin/mycli -u root --password=$MYSQL_PASSWORD --local-infile=1 --database=wam_verona'
alias vercc='/home/zone8/.composer/vendor/bin/cache-clean.js --watch --directory /var/www/html/wearemagneto/projects/verona-group/html/'

# Verona Stone
alias vs='cd /var/www/html/wearemagneto/projects/verona-group/html '
alias vsmr='cd /var/www/html/wearemagneto/projects/verona-group/html && /usr/bin/php7.2 -v && /usr/bin/php7.2 /var/www/html/n98-magerun2.phar --ansi'
alias vsphp='cd /var/www/html/wearemagneto/projects/verona-group/html && /usr/bin/php7.2 -v && /usr/bin/php7.2'
alias vsreset='xddphp72 && cd /var/www/html/wearemagneto/projects/verona-group/scripts/ && ./dev/reset-everything.sh && cd ../html'
alias vsxe='cd /var/www/html/wearemagneto/projects/verona-group/html && /var/www/html/magento-scripts/dev/enable-xdebug-php72.sh'
alias vsxd='cd /var/www/html/wearemagneto/projects/verona-group/html && /var/www/html/magento-scripts/dev/disable-xdebug-php72.sh'
alias vsmy='cd /var/www/html/wearemagneto/projects/verona-group/html && /usr/bin/mycli -u root --password=$MYSQL_PASSWORD --local-infile=1 --database=wam_verona'
alias vscc='/home/zone8/.composer/vendor/bin/cache-clean.js --watch --directory /var/www/html/wearemagneto/projects/verona-group/html/'

# Paving Direct
alias pd='cd /var/www/html/wearemagneto/projects/pavingdirect.com/html '
alias pdmr='cd /var/www/html/wearemagneto/projects/pavingdirect.com/html && /usr/bin/php7.1 -v && /usr/bin/php7.1 /var/www/html/n98-magerun2-3.2.0.phar --ansi'
alias pdphp='cd /var/www/html/wearemagneto/projects/pavingdirect.com/html && /usr/bin/php7.1 -v && /usr/bin/php7.1'
alias pdreset='xddphp71 && cd ../scripts/ && ./dev/reset-everything.sh && cd ../html'
alias pdxe='cd /var/www/html/wearemagneto/projects/pavingdirect.com/html && /var/www/html/magento-scripts/dev/enable-xdebug-php71.sh'
alias pdxd='cd /var/www/html/wearemagneto/projects/pavingdirect.com/html && /var/www/html/magento-scripts/dev/disable-xdebug-php71.sh'
alias pdmy='cd /var/www/html/wearemagneto/projects/pavingdirect.com/html && /usr/bin/mycli -u root --password=$MYSQL_PASSWORD --database=wam_pavingdirect'
alias pdcc='/home/zone8/.composer/vendor/bin/cache-clean.js --watch --directory /var/www/html/wearemagneto/projects/pavingdirect.com/html/'

# Dusk
alias d='cd /var/www/html/wearemagneto/projects/dusk/html '
alias dmr='cd /var/www/html/wearemagneto/projects/dusk/html && /usr/bin/php7.3 -v && /usr/bin/php7.3 /var/www/html/n98-magerun2.phar --ansi'
alias dphp='cd /var/www/html/wearemagneto/projects/dusk/html && /usr/bin/php7.3 -v && /usr/bin/php7.3'
#alias dreset='d && xddphp73 && dphp /usr/local/bin/composer install && cd ../scripts/ && ./dev/reset-everything.sh && d'
alias dreset='d && dphp /usr/local/bin/composer install && cd ../scripts/ && ./dev/reset-everything.sh && d'
#alias dxe='cd /var/www/html/wearemagneto/projects/dusk/html && /var/www/html/magento-scripts/dev/enable-xdebug-php73.sh'
#alias dxd='cd /var/www/html/wearemagneto/projects/dusk/html && /var/www/html/magento-scripts/dev/disable-xdebug-php73.sh'
alias dmy='cd /var/www/html/wearemagneto/projects/dusk/html && /usr/bin/mycli -u root --password=$MYSQL_PASSWORD --database=wam_dusk'
alias dcc='/home/zone8/.composer/vendor/bin/cache-clean.js --watch --directory /var/www/html/wearemagneto/projects/dusk/html/'

# Magento 23 Example Modules
alias m23em='cd /var/www/html/m2/research/m23-example-modules/html '
alias m23emmr='cd /var/www/html/m2/research/m23-example-modules/html && /usr/bin/php7.3 -v && /usr/bin/php7.3 /var/www/html/n98-magerun2.phar --ansi'
alias m23emphp='cd /var/www/html/m2/research/m23-example-modules/html && /usr/bin/php7.3 -v && /usr/bin/php7.3'
#alias m23emreset='xddphp71 && xddphp72 && xddphp73 && m23emphp /usr/local/bin/composer install && cd ../scripts/ && ./dev/reset-everything.sh && cd ../html'
alias m23emreset='xddphp71 && xddphp72 && m23emphp /usr/local/bin/composer install && cd ../scripts/ && ./dev/reset-everything.sh && cd ../html'
#alias m23emxe='cd /var/www/html/m2/research/m23-example-modules/html && /var/www/html/magento-scripts/dev/enable-xdebug-php73.sh'
#alias m23emxd='cd /var/www/html/m2/research/m23-example-modules/html && /var/www/html/magento-scripts/dev/disable-xdebug-php73.sh'
alias m23emmy='cd /var/www/html/m2/research/m23-example-modules/html && /usr/bin/mycli -u root --password=$MYSQL_PASSWORD --database=m23_example_modules'
alias m23emcc='/home/zone8/.composer/vendor/bin/cache-clean.js --watch --directory /var/www/html/m2/research/m23-example-modules/html/'

# Magento 24 Example Modules
alias m24em='cd /var/www/html/m2/research/m24-example-modules/html '
alias m24emphp='m24em && /usr/bin/php8.1 -v && /usr/bin/php8.1'
alias m24emmr='m24emphp n98-magerun2.phar --ansi'
alias m24emreset='m24emphp /usr/local/bin/composer2 install && cd ../scripts/ && ./dev/reset-everything.sh && cd ../html && m24emmr setup:static-content:deploy -f en_GB --theme Magento/backend && m24emmr setup:static-content:deploy -f en_US --theme Magento/backend && m24emmr setup:static-content:deploy -f en_GB --theme Magento/luma && m24emmr setup:static-content:deploy -f en_US --theme Magento/luma'
alias m24emxe='m24em && /var/www/html/magento-scripts/dev/enable-xdebug-php81.sh'
alias m24emxd='m24em && /var/www/html/magento-scripts/dev/disable-xdebug-php81.sh'
alias m24emmy='m24em && /usr/bin/mycli -u root --password=$MYSQL_PASSWORD --database=m24_example_modules'
alias m24emcc='/home/zone8/.composer/vendor/bin/cache-clean.js --watch --directory /var/www/html/m2/research/m24-example-modules/html'

# reactphp-playground-magento2
alias rppm2='cd /var/www/html/async-php/reactphp-playground-magento2/htdocs '
alias rppm2php='rppm2 && /usr/bin/php7.3 -v && /usr/bin/php7.3'
alias rppm2mr='rppm2 && /usr/bin/php7.3 -v && /usr/bin/php7.3 /var/www/html/n98-magerun2.phar --ansi'
#alias rppm2reset='xddphp71 && xddphp72 && xddphp73 && rppm2php /usr/local/bin/composer install && cd ../scripts/ && ./dev/reset-everything.sh && cd ../html'
alias rppm2reset='xddphp71 && xddphp72 && rppm2php /usr/local/bin/composer install && cd ../scripts/ && ./dev/reset-everything.sh && cd ../html'
#alias rppm2xe='rppm2 && /var/www/html/magento-scripts/dev/enable-xdebug-php73.sh'
#alias rppm2xd='rppm2 && /var/www/html/magento-scripts/dev/disable-xdebug-php73.sh'
alias rppm2my='rppm2 && /usr/bin/mycli -u root --password=$MYSQL_PASSWORD --database=m23_reactphp_playground'
alias rppm2cc='/home/zone8/.composer/vendor/bin/cache-clean.js --watch --directory /var/www/html/async-php/reactphp-playground-magento2/htdocs/'

#
# Magento 2
# With user check. Not needed on zone8-aurora, but maybe useful on other systems
#
alias magento2='cd /var/www && if [ `whoami` == `stat -c '%U' bin/magento` ]; then bin/magento "$@"; else echo "bin/magento should be run as user `stat -c '%U' bin/magento`";fi'

#
# MySQL
#
# Set password using 'export MYSQL_PASSWORD={{mysql_password_goes_here}}'
alias my='/usr/bin/mycli -u root --password=$MYSQL_PASSWORD'
alias mydump='mysqldump -u root --password=$MYSQL_PASSWORD'

#
# Laravel
#
alias laravel='/usr/bin/php7.4 -v && /usr/bin/php7.4 /home/zone8/.composer/vendor/bin/laravel'

#
# Misc
#
alias nn='nano'

#
# Generate TOC for Markdown files
#
alias toc='/var/www/html/gh-md-toc'

#
# Java
#
export JAVA_HOME=/usr/bin/java
