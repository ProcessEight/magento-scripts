# Download archive direct from ES
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.8.4.deb
# Download checksum direct from ES
wget https://artifacts.elastic.co/downloads/elasticsearch/elasticsearch-6.8.4.deb.sha512
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
sudo bin/elasticsearch-plugin install analysis-icu
sudo bin/elasticsearch-plugin install analysis-phonetic
sudo service elasticsearch restart
# Enable Smile modules
/usr/bin/php7.3 -v && /usr/bin/php7.3 /var/www/html/n98-magerun2.phar --ansi mod:en Smile_ElasticsuiteCore Smile_ElasticsuiteCatalog Smile_ElasticsuiteCatalogRule Smile_ElasticsuiteCatalogOptimizer Smile_ElasticsuiteTracker Smile_ElasticsuiteSwatches Smile_ElasticsuiteThesaurus Smile_ElasticsuiteAnalytics Smile_ElasticsuiteVirtualCategory Smile_ElasticsuiteAdminNotification
# Reset everything
xddphp72 && cd ../scripts/ && ./dev/reset-everything.sh && cd ../html
# Create ES indexes
/usr/bin/php7.3 -v && /usr/bin/php7.3 /var/www/html/n98-magerun2.phar --ansi ind:reset && /usr/bin/php7.3 -v && /usr/bin/php7.3 /var/www/html/n98-magerun2.phar --ansi ind:rei
