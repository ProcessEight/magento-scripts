<?php
/**
 * Run this file using:
 * $ dep deploy.php
 *
 * Other considerations:
 * - You'll need to add a deployment to the git repo and add the server fingerprint to the know_hosts file for a truly automated git clone
 *
 */
namespace Deployer;

require_once 'recipe/common.php';

// Configuration

set('ssh_type', 'native');
set('ssh_multiplexing', true);

set('repository', 'ssh://git@bitbucket.org/purenetgit/english-braids.git');

set('shared_files', [
    'app/etc/env.php',
    'var/.maintenance.ip',
]);
set('shared_dirs', [
    'var/log',
    'var/backups',
    'pub/media',
]);
set('writable_dirs', [
    'var',
    'pub/static',
    'pub/media',
]);
set('writable_mode', 'chmod');
set('writable_use_sudo', true);
set('clear_paths', [
    'var/generation/*',
    'var/cache/*',
]);

set('MAGENTO2_PUBLIC_KEY', 'e105c5c2830848acb86e59092f62ef8d');
set('MAGENTO2_PRIVATE_KEY', 'b3674905a16e118b428893c7c413ef45');

// Servers

server('production', '10.10.10.21')
    ->user('root')
    ->identityFile()
    ->set('deploy_path', '/var/www/html/deployer-magento2')
;

// Tasks

// Need to override this command here to force it to cd into htdocs (where the composer.json is)
task('deploy:vendors', function () {
    run('cd {{deploy_path}}/current/htdocs && {{env_vars}} {{bin/composer}} {{composer_options}}');
});

task('magento2:prepare-composer', function () {
    run('mkdir -p ~/.composer && echo "{
   \"http-basic\": {
      \"repo.magento.com\": {
         \"username\": \"{{MAGENTO2_PUBLIC_KEY}}\",
         \"password\": \"{{MAGENTO2_PRIVATE_KEY}}\"
      }
   }
}" > ~/.composer/auth.json');
});

desc('Enable all modules');
task('magento:enable', function () {
    run("{{bin/php}} {{release_path}}/htdocs/bin/magento module:enable --all");
});

desc('Compile magento di');
task('magento:compile', function () {
    run("{{bin/php}} {{release_path}}/bin/magento setup:di:compile");
});

//desc('Optimise composer autoloader');
//task('magento:composer:optimise-autoloader', function () {
//    run("{{bin/composer}} composer dump-autoload -o");
//});

desc('Deploy assets');
task('magento:deploy:assets', function () {
    run("{{bin/php}} {{release_path}}/bin/magento setup:static-content:deploy");
});

desc('Enable maintenance mode');
task('magento:maintenance:enable', function () {
    run("if [ -d $(echo {{deploy_path}}/current) ]; then {{bin/php}} {{deploy_path}}/current/bin/magento maintenance:enable; fi");
});

desc('Disable maintenance mode');
task('magento:maintenance:disable', function () {
    run("if [ -d $(echo {{deploy_path}}/current) ]; then {{bin/php}} {{deploy_path}}/current/bin/magento maintenance:disable; fi");
});

desc('Upgrade magento database');
task('magento:upgrade:db', function () {
    run("{{bin/php}} {{release_path}}/bin/magento setup:db-schema:upgrade");
    run("{{bin/php}} {{release_path}}/bin/magento setup:db-data:upgrade");
});

desc('Flush Magento Cache');
task('magento:cache:flush', function () {
    run("{{bin/php}} {{release_path}}/bin/magento cache:flush");
});

desc('Magento2 deployment operations');
task('deploy:magento', [
    'magento:enable',
    'magento:compile',
    'magento:deploy:assets',
    'magento:maintenance:enable',
    'magento:upgrade:db',
    'magento:cache:flush',
    'magento:maintenance:disable'
]);

desc('Deploy your project');
task('deploy', [
    'deploy:prepare',
    'deploy:lock',
    'deploy:release',
    'deploy:update_code',
    'deploy:shared',
    'deploy:writable',
    'deploy:vendors',
    'deploy:clear_paths',
    'deploy:magento',
    'deploy:symlink',
    'deploy:unlock',
    'cleanup',
    'success'
]);

// [Optional] if deploy fails automatically unlock.
after('deploy:failed', 'deploy:unlock');
