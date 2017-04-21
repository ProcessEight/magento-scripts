echo "Cleaning htdocs/var/cache/* htdocs/var/generation/* htdocs/var/di/* htdocs/var/page_cache/* htdocs/var/tmp/* htdocs/var/view_preprocessed/*"
rm -rf htdocs/var/cache/* htdocs/var/generation/* htdocs/var/di/* htdocs/var/page_cache/* htdocs/var/tmp/* htdocs/var/view_preprocessed/css/frontend/* htdocs/var/view_preprocessed/js/frontend/* htdocs/var/view_preprocessed/source/frontend/*
echo "Cleaning htdocs/pub/static/* " 
rm -rf htdocs/pub/static/frontend/* htdocs/pub/static/_requirejs/frontend/*
echo "Cleaning automated testing sandbox files " 
rm -rf htdocs/dev/tests/integration/tmp/sandbox-* 
rm -rf htdocs/dev/tests/unit/tmp/sandbox-* 
#echo "Clearing all caches in redis for project "
#redis-cli -n 2 flushdb
#redis-cli -n 3 flushdb
echo "Running setup:upgrade " 
../../htdocs/bin/magento setup:upgrade
../../htdocs/bin/magento cache:disable
echo "Clearing caches "
../../htdocs/bin/magento cache:flush
../../htdocs/bin/magento cache:clean
echo "All done!"
