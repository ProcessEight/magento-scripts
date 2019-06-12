#
# Docker
#
alias d='/usr/bin/docker'
alias dc='/usr/local/bin/docker-compose'

#
# PHP
#
alias php56='/usr/bin/php5.6'
alias php70='/usr/bin/php7.0'
alias php71='/usr/bin/php7.1'
alias php72='/usr/bin/php7.2'
alias php73='/usr/bin/php7.3'

#
# PHP Tools
#
alias phpcs='/home/simon/.composer/vendor/bin/phpcs '
alias composer='/usr/bin/php7.2 -v && /usr/bin/php7.2 -n -d extension=bcmath.so -d extension=ctype.so -d extension=curl.so -d extension=dom.so -d extension=gd.so -d extension=gettext.so -d extension=iconv.so -d extension=intl.so -d extension=json.so -d extension=mbstring.so -d extension=mysqlnd.so -d extension=pdo.so -d extension=pdo_mysql.so -d extension=phar.so -d extension=posix.so -d extension=readline.so -d extension=simplexml.so -d extension=soap.so -d extension=sockets.so -d extension=sysvmsg.so -d extension=sysvsem.so -d extension=sysvshm.so -d extension=tokenizer.so -d extension=xml.so -d extension=xmlwriter.so -d extension=xsl.so -d extension=zip.so /usr/local/bin/composer --ansi'
alias rbm='robo --load-from /var/www/html/magento-scripts/robo/ '
alias dpd='php -n /home/simon/tools/dephpend '
alias xdephp56='/var/www/html/magento-scripts/dev/enable-xdebug-php56.sh'
alias xddphp56='/var/www/html/magento-scripts/dev/disable-xdebug-php56.sh'
alias xdephp70='/var/www/html/magento-scripts/dev/enable-xdebug-php70.sh'
alias xddphp70='/var/www/html/magento-scripts/dev/disable-xdebug-php70.sh'
alias xdephp71='/var/www/html/magento-scripts/dev/enable-xdebug-php71.sh'
alias xddphp71='/var/www/html/magento-scripts/dev/disable-xdebug-php71.sh'
alias xdephp72='/var/www/html/magento-scripts/dev/enable-xdebug-php72.sh'
alias xddphp72='/var/www/html/magento-scripts/dev/disable-xdebug-php72.sh'
alias xdephp73='/var/www/html/magento-scripts/dev/enable-xdebug-php73.sh'
alias xddphp73='/var/www/html/magento-scripts/dev/disable-xdebug-php73.sh'

#
# Projects
#
alias wwwd='cd /var/www/html/'
alias wwwm2r='cd /var/www/html/m2-research/'
alias wwwm23='cd /var/www/html/m2-research/m23-example-modules/htdocs/'
alias wwwmem='cd /var/www/html/magento225-example-modules/htdocs/'
alias wwwws='cd /var/www/html/watson/watson-safari/'

alias wwwj='cd /var/www/html/jacobs-turner/'
alias wwwjt='cd /var/www/html/jacobs-turner/'

alias wwwa='cd /var/www/html/jacobs-turner/ansible/'
alias wwwdm2='cd /var/www/html/jacobs-turner/dlxm2/html/'
alias wwwtm2='cd /var/www/html/jacobs-turner/trespass-m2/html/'
alias wwwtpwa='cd /var/www/html/jacobs-turner/trespass-pwa/pwa-studio/'

#
# Magento 1
#
alias mr='/usr/bin/php7.1 /var/www/html/n98-magerun.phar --ansi'
alias mr1='/usr/bin/php7.1 /var/www/html/n98-magerun.phar --ansi'

#
# Magento 2
#
alias mm='/usr/bin/php7.2 -v && /usr/bin/php7.2 -f bin/magento -- --ansi'
alias mr2='/usr/bin/php7.2 -v && /usr/bin/php7.2 /var/www/html/n98-magerun2.phar --ansi'
alias pes='/usr/bin/php7.2 -v && /usr/bin/php7.2 /var/www/html/pestle.phar'
alias pestle='/usr/bin/php7.2 -v && /usr/bin/php7.2 /var/www/html/pestle.phar'
alias wwwdata='sudo su - www-data -s /bin/bash '

#
# Magento 2
# With user check. Not needed on zone8-aurora, but maybe useful on other systems
#
alias magento2='cd /var/www && if [ `whoami` == `stat -c '%U' bin/magento` ]; then bin/magento "$@"; else echo "bin/magento should be run as user `stat -c '%U' bin/magento`";fi'

#
# MySQL
#
# Set password using 'export MYSQL_PASSWORD={{mysql_password_goes_here}}'
alias my='mycli -u root --password=$MYSQL_PASSWORD'
alias mydump='mysqldump -u root --password=$MYSQL_PASSWORD'

#
# Misc
#
alias nn='nano'

#
# Vagrant
#

alias vg='vagrant'

#
# Generate TOC for Markdown files
#
alias toc='/var/www/html/gh-md-toc'
