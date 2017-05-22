echo `pwd`/../htdocs
echo "Cleaning...
`pwd`/../htdocs/var/cache/*
`pwd`/../htdocs/var/generation/*
`pwd`/../htdocs/var/di/*
`pwd`/../htdocs/var/tmp/*
`pwd`/../htdocs/var/page_cache/*
`pwd`/../htdocs/var/view_preprocessed/css/frontend/*
`pwd`/../htdocs/var/view_preprocessed/js/frontend/*
`pwd`/../htdocs/var/view_preprocessed/source/frontend/*
`pwd`/../htdocs/pub/static/frontend/*
`pwd`/../htdocs/pub/static/_requirejs/frontend/*"
rm -rf `pwd`/../htdocs/var/cache/* `pwd`/../htdocs/var/generation/* `pwd`/../htdocs/var/di/* `pwd`/../htdocs/var/tmp/* 
rm -rf `pwd`/../htdocs/var/page_cache/* `pwd`/../htdocs/var/view_preprocessed/css/frontend/* `pwd`/../htdocs/var/view_preprocessed/js/frontend/* `pwd`/../htdocs/var/view_preprocessed/source/frontend/*
rm -rf `pwd`/../htdocs/pub/static/frontend/* `pwd`/../htdocs/pub/static/_requirejs/frontend/*
echo "Cleaning automated testing sandbox files " 
rm -rf `pwd`/../htdocs/dev/tests/integration/tmp/sandbox-*
rm -rf `pwd`/../htdocs/dev/tests/unit/tmp/sandbox-*
#echo "Clearing all caches in redis for project "
#redis-cli -n 2 flushdb
#redis-cli -n 3 flushdb
echo "Running setup:upgrade " 
`pwd`/../htdocs/bin/magento setup:upgrade
`pwd`/../htdocs/bin/magento cache:disable
`pwd`/../htdocs/bin/magento cache:enable full_page
echo "Clearing caches "
`pwd`/../htdocs/bin/magento cache:flush
`pwd`/../htdocs/bin/magento cache:clean
echo "All done!"
