#!/usr/bin/env bash

#
# Setup elasticsearch for M2
#
# Assumptions
#
# That the M2 instance is properly installed
#

# This script must be run from inside the scripts folder, i.e.
# $ cd /var/www/html/your-project.local/scripts
# $ ./update/10-prepare-composer.sh
CONFIG_M2_FILEPATH=`pwd`/config-m2.env
PROJECT_ROOT_PATH=`pwd`
if [[ 'scripts' != ${PROJECT_ROOT_PATH: -7} ]]; then
    echo "
#
# The script detected you are running this script from an invalid location.
# Make sure you are running this script from the scripts directory.
# The script detected $PROJECT_ROOT_PATH
#
# Script cannot continue. Exiting now.
#"
exit
fi
if [[ ! -f $CONFIG_M2_FILEPATH ]]; then
    echo "
#
# Could not detect config-m2.env.
# Create one first in $PROJECT_ROOT_PATH/config-m2.env
# and make sure you are running this script from the scripts directory.
#
# Script cannot continue. Exiting now.
#"
    exit
fi
if [[ ! -f ~/.composer/auth.json ]]; then
    echo "
#
# The script has detected that ~/.composer/auth.json does not exist.
# The script will not create it.
# To continue, create it first using:
# $ composer config -g http-basic.repo.magento.com <public_key> <private_key>
#
# Script cannot continue. Exiting now.
#"
    exit
fi

# Import config variables
set -a; . `pwd`/config-m2.env

cd $MAGENTO2_ENV_WEBROOT

if [[ ! -f ./elasticsearch-6.8.4.deb ]]; then
    # Download archive direct from ES
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.8.4.deb
    # Download checksum direct from ES
    wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.8.4.deb.sha512
fi

# Validate checksum
shasum -a 512 -c elasticsearch-6.8.4.deb.sha512
# Install ES
sudo dpkg -i elasticsearch-6.8.4.deb
# Configure ES so it starts on boot
sudo update-rc.d elasticsearch defaults 95 10
# Start ES
sudo -i service elasticsearch start
# Check to see if Smile modules are installed
/usr/bin/php7.3 -v && /usr/bin/php7.3 /var/www/html/n98-magerun2.phar --ansi mod:st
# Enable Smile modules
/usr/bin/php7.3 -v && /usr/bin/php7.3 /var/www/html/n98-magerun2.phar --ansi mod:en Smile_ElasticsuiteCore Smile_ElasticsuiteCatalog Smile_ElasticsuiteCatalogRule Smile_ElasticsuiteCatalogOptimizer Smile_ElasticsuiteTracker Smile_ElasticsuiteSwatches Smile_ElasticsuiteThesaurus Smile_ElasticsuiteAnalytics Smile_ElasticsuiteVirtualCategory Smile_ElasticsuiteAdminNotification
# Verify ES is running
curl "localhost:9200/_nodes/settings?pretty=true"
# Install ES plugins required for M2
cd /usr/share/elasticsearch
bin/elasticsearch-plugin install analysis-phonetic
sudo bin/elasticsearch-plugin remove analysis-icu
sudo bin/elasticsearch-plugin install analysis-icu
sudo bin/elasticsearch-plugin remove analysis-phonetic
sudo bin/elasticsearch-plugin install analysis-phonetic
sudo service elasticsearch restart

cd $MAGENTO2_ENV_WEBROOT

# Enable Smile modules
/usr/bin/php7.3 -v && /usr/bin/php7.3 /var/www/html/n98-magerun2.phar --ansi mod:en Smile_ElasticsuiteCore Smile_ElasticsuiteCatalog Smile_ElasticsuiteCatalogRule Smile_ElasticsuiteCatalogOptimizer Smile_ElasticsuiteTracker Smile_ElasticsuiteSwatches Smile_ElasticsuiteThesaurus Smile_ElasticsuiteAnalytics Smile_ElasticsuiteVirtualCategory Smile_ElasticsuiteAdminNotification
# Reset everything
xddphp72 && cd ../scripts/ && ./dev/reset-everything.sh && cd ../html
# Create ES indexes
/usr/bin/php7.3 -v && /usr/bin/php7.3 /var/www/html/n98-magerun2.phar --ansi ind:reset && /usr/bin/php7.3 -v && /usr/bin/php7.3 /var/www/html/n98-magerun2.phar --ansi ind:rei
