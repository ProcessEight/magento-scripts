#
# Docker
#
alias d='/usr/bin/docker'
alias dc='/usr/local/bin/docker-compose'

#
# PHP
#
alias php71='/usr/bin/php7.1 -v && /usr/bin/php7.1'
alias php72='/usr/bin/php7.2 -v && /usr/bin/php7.2'
alias php73='/usr/bin/php7.3 -v && /usr/bin/php7.3'

#
# PHP Tools
#
alias phpcs='~/.composer/vendor/bin/phpcs '
#alias composer='/usr/bin/php7.3 -v && /usr/bin/php7.3 -n -d extension=bcmath.so -d extension=ctype.so -d extension=curl.so -d extension=dom.so -d extension=gd.so -d extension=gettext.so -d extension=iconv.so -d extension=intl.so -d extension=json.so -d extension=mbstring.so -d extension=mysqlnd.so -d extension=pdo.so -d extension=pdo_mysql.so -d extension=phar.so -d extension=posix.so -d extension=readline.so -d extension=simplexml.so -d extension=soap.so -d extension=sockets.so -d extension=sysvmsg.so -d extension=sysvsem.so -d extension=sysvshm.so -d extension=tokenizer.so -d extension=xml.so -d extension=xmlwriter.so -d extension=xsl.so -d extension=zip.so /usr/local/bin/composer --ansi '
alias composer='/usr/bin/php7.3 -v && /usr/bin/php7.3 /usr/local/bin/composer --ansi '
alias rbm='robo --load-from /var/www/html/magento-scripts/robo/ '
alias dpd='php -n ~/tools/dephpend '
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
alias m2rnd='cd /var/www/html/m2/research/'
alias m23em='cd /var/www/html/m2/research/m23-example-modules/html/'
alias m22em='cd /var/www/html/m2/research/m225-example-modules/htdocs/'
alias wat='cd /var/www/html/watson/watson-safari/'

alias jt='cd /var/www/html/jacobs-turner/'
alias wam='cd /var/www/html/wearemagneto/'

alias ans='cd /var/www/html/jacobs-turner/ansible/'
alias dm2='cd /var/www/html/jacobs-turner/projects/dlxm2/html/'
alias tm2='cd /var/www/html/jacobs-turner/projects/trespass-m2/html/'
alias tm2pr='cd /var/www/html/jacobs-turner/projects/trespass-m2-pr-pull-request-code-review/html/'
alias jtp='cd /var/www/html/jacobs-turner/projects/'
alias jtm='cd /var/www/html/jacobs-turner/modules/'
alias tpwa='cd /var/www/html/jacobs-turner/trespass-pwa/pwa-studio/'

#
# Magento 1
#
alias mr='/usr/bin/php7.1 /var/www/html/n98-magerun.phar --ansi'
alias mr1='/usr/bin/php7.1 /var/www/html/n98-magerun.phar --ansi'

#
# Magento 2
#
alias bm71='/usr/bin/php7.1 -v && /usr/bin/php7.1 -f bin/magento -- --ansi'
alias bm72='/usr/bin/php7.2 -v && /usr/bin/php7.2 -f bin/magento -- --ansi'
alias bm73='/usr/bin/php7.3 -v && /usr/bin/php7.3 -f bin/magento -- --ansi'

alias mr71='/usr/bin/php7.1 -v && /usr/bin/php7.1 /var/www/html/n98-magerun2.phar --ansi'
alias mr72='/usr/bin/php7.2 -v && /usr/bin/php7.2 /var/www/html/n98-magerun2.phar --ansi'
alias mr73='/usr/bin/php7.3 -v && /usr/bin/php7.3 /var/www/html/n98-magerun2.phar --ansi'

alias pes='/usr/bin/php7.3 -v && /usr/bin/php7.3 /var/www/html/pestle.phar'
alias pestle='/usr/bin/php7.3 -v && /usr/bin/php7.3 /var/www/html/pestle.phar'
alias wwwdata='sudo su - www-data -s /bin/bash '

#
# We Are Magneto
#
alias pdmr='cd /var/www/html/wearemagneto/projects/pavingdirect.com/html && /usr/bin/php7.1 -v && /usr/bin/php7.1 n98-magerun2-3.2.0.phar --ansi'

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

#
# Java
#
export JAVA_HOME=/usr/bin/java
