#
# Docker
#
alias dc='/usr/local/bin/docker-compose '

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
alias com='/usr/bin/php7.1 -n -d extension=bcmath.so -d extension=ctype.so -d extension=curl.so -d extension=dom.so -d extension=gd.so -d extension=gettext.so -d extension=iconv.so -d extension=intl.so -d extension=json.so -d extension=mbstring.so -d extension=mcrypt.so -d extension=mysqlnd.so -d extension=pdo.so -d extension=pdo_mysql.so -d extension=phar.so -d extension=posix.so -d extension=readline.so -d extension=simplexml.so -d extension=soap.so -d extension=sockets.so -d extension=sysvmsg.so -d extension=sysvsem.so -d extension=sysvshm.so -d extension=tokenizer.so -d extension=xml.so -d extension=xmlwriter.so -d extension=xsl.so -d extension=zip.so /usr/local/bin/composer '
alias rbm='robo --load-from /var/www/html/magento2-deployment/robo/ '
alias dpd='php -n /home/simon/tools/dephpend '
alias xdephp56='/var/www/html/magento2-deployment/dev/enable-xdebug-php56.sh'
alias xddphp56='/var/www/html/magento2-deployment/dev/disable-xdebug-php56.sh'
alias xdephp70='/var/www/html/magento2-deployment/dev/enable-xdebug-php70.sh'
alias xddphp70='/var/www/html/magento2-deployment/dev/disable-xdebug-php70.sh'
alias xdephp71='/var/www/html/magento2-deployment/dev/enable-xdebug-php71.sh'
alias xddphp71='/var/www/html/magento2-deployment/dev/disable-xdebug-php71.sh'
alias xdephp72='/var/www/html/magento2-deployment/dev/enable-xdebug-php72.sh'
alias xddphp72='/var/www/html/magento2-deployment/dev/disable-xdebug-php72.sh'

#
# Projects
#
alias wwwd='cd /var/www/html'
alias wwwdfl='cd /var/www/html/dfl/htdocs'
alias wwwdfl167='cd /var/www/html/dfl-167/htdocs'
alias wwwhat='cd /var/www/html/hat/htdocs'
alias wwwll='cd /var/www/html/ll/htdocs'
alias wwwmor='cd /var/www/html/mor/htdocs'
alias wwwnsi='cd /var/www/html/nsi-nails-systems-international/htdocs'
alias wwwwsp='cd /var/www/html/wsp-weather-stop/htdocs'

#
# Magento 1
#
alias mr='/var/www/html/n98-magerun.phar '
alias mr1='/var/www/html/n98-magerun.phar '

#
# Magento 2
#
alias mm='/usr/bin/php7.1 -f bin/magento '
alias mr2='/usr/bin/php7.1 /var/www/html/n98-magerun2.phar '
alias pes='/var/www/html/pestle.phar'
alias wwwdata='sudo su - www-data -s /bin/bash '

#
# MySQL
#
alias my='mycli -u root --password=password '
alias mydump='mysqldump -u root --password=password '
