# Magento 2 Deployment

## Setup a new instance of an existing project

This guide assumes that you have:

* A database dump from an existing instance of the project
* Access to the project git repo
* A cloned copy of the magento2-deployment repo, checked out in another directory

If you don't have a copy of the `magento2-deployment` repo checked out, check it out now using this command: 
```bash
git clone git@bitbucket.org:purenetgit/magento2-deployment.git
```

The instructions are specific to Ubuntu, but can be adapted to Windows/Mac.

Let's begin.

1. Clone the project repo:
    ```bash
    $ git clone git@bitbucket.org:purenetgit/english-braids.git englishbraids.test.dev
    ```
1. Create a sym-link to the `magento2-deployment` scripts:
    ```bash
    $ cd englishbraids.test.dev
    $ mkdir scripts
    $ cd scripts
    $ ln -s /var/www/html/magento2-deployment/update-m2 update-m2
    ```
1. Now create a environment variable file called `config-m2.env`. You can copy the sample one from the `magento-deployment` repo:
    ```bash
    $ cp /var/www/html/magento2-deployment/config-m2.env.sample config-m2.env
    ```
1. Update the config-m2.env file accordingly. See below for a list of the values and what the acceptable values are.
    ```bash
    $ nano config-m2.env
    ```
1. Now run the deployment scripts. You can run them individually (in order) or run the `05-run-all-steps.sh` script to do everything in one go.
    ```bash
    $ ./update-m2/05-run-all-steps.sh
    ```

Your Magento 2 project is now installed and ready to run.

If you're developing locally and need to create a virtual host, you can use the `setup-magento2-localhost.sh` script in the `magento2-deployment` repository:
```bash
$ cd /var/www/html/englishbraids.test.dev/scripts
$ ln -s /var/www/html/magento2-deployment/dev dev
$ sudo ./dev/setup-magento2-localhost.sh
```
This script will create an Nginx virtual host and add an entry to your hosts file.

## Troubleshooting

```bash
# When running bin/magento setup:static-content:deploy
Warning: Invalid argument supplied for foreach() in /var/www/html/englishbraids.test.dev/htdocs/vendor/magento/module-store/Model/Config/Processor/Fallback.php on line 125  
```
Magento 2 is not installed, or is not installed correctly. Magento 2 needs to be installed to generate static content.

```bash
There are no commands defined in tapp/design/frontend/florenceroby/default/template/checkout/cart.phtml: This logic should really be moved into a block class. There's also a typo in collegKitInBasket.
he "cache" namespace.  
```
This can happen with any command, not just commands in the `cache` namespace. Magento 2 has hit upon an internal error, usually when loading the configuration. Clear the `var/generation`, `var/di` and cache folders and try running the command again.

```bash
Could not scan for classes inside "/var/www/html/englishbraids.test/htdocs/vendor/colinmollenhour/cache-backend-redis/Cm/Cache/Backend/Redis.php" which does not appear to be a file nor a folder  
```
The composer cache is corrupt. Clean it using:
```bash
$ composer cache-clean
$ rm -rf htdocs/composer.lock htdocs/vendor/
```
The re-run the `composer install` command.

## Install locally

To use the scripts to install a new Magento 2 instance:

```bash
$ mkdir projectname
$ cd projectname
$ ln -s /var/www/html/magento2-deployment/install install
$ cp /var/www/html/magento2-deployment/config-m2.env.sample config-m2.env
```

Now update the `config-m2.env` file, then:

```bash
$ cd /var/www/html/projectname
$ ./install/05-run-all-steps.sh
```

## Install with Ansible

To use Ansible to install a new Magento 2 instance:

Add the hosts you want to run this Playbook on to Ansible:
```bash
$ nano /etc/ansible/hosts
```

Update the config-m2.env file to add platform-specific values
```bash
cp config-m2.env.sample config-m2.env
```

Run this command to install Magento 2:
```bash
$ ansible-playbook install/m2.yml
```

## Update with Ansible

To use Ansible to update an existing Magento 2 instance:

Add the hosts you want to run this Playbook on to Ansible:
```bash
$ nano /etc/ansible/hosts
```

Update the config-m2.env file to add platform-specific values
```bash
cp config-m2.env.sample config-m2.env
```

Run this command to install Magento 2:
```bash
$ ansible-playbook update/m2.yml
```

## Environment variable reference

### Composer
Composer-specific settings

| Variable name  	| Default value  	| Description  	| Sample value  	|
|---	|---	|---	|---	|
| MAGENTO2_PUBLIC_KEY    	| Empty  	| The public key from your Magento.com account  	| `a1b2c3c2830848acb86e59092f62ef8d`	|
| MAGENTO2_PRIVATE_KEY  	| Empty  	| The private key from your Magento.com account  	| `b3674905a16e118b428893c7c43c2b1a`  	|

### Database
Database management settings

| Variable name  	| Default value  	| Description  	| Sample value  	|
|---	|---	|---	|---	|
MAGENTO2_DB_HOSTNAME | None | The hostname of the server MySQL is running on. Usually localhost. | `localhost` |
MAGENTO2_DB_ROOTUSERNAME "--user=root"
MAGENTO2_DB_ROOTPASSWORD "--password=password"
MAGENTO2_DB_NAME
MAGENTO2_DB_USERNAME
MAGENTO2_DB_PASSWORD
MAGENTO2_DB_DUMPNAME
MAGENTO2_DB_BACKUPFIRST

### Magento 2 Admin
Admin-specific settings

| Variable name  	| Default value  	| Description  	| Sample value  	|
|---	|---	|---	|---	|
MAGENTO2_ADMIN_FIRSTNAME
MAGENTO2_ADMIN_LASTNAME
MAGENTO2_ADMIN_EMAIL
MAGENTO2_ADMIN_USERNAME
MAGENTO2_ADMIN_PASSWORD
MAGENTO2_ADMIN_FRONTNAME

### Magento 2 Locale
Configure locale settings

| Variable name  	| Default value  	| Description  	| Sample value  	|
|---	|---	|---	|---	|
MAGENTO2_LOCALE_CODE=en_GB
MAGENTO2_LOCALE_CURRENCY=GBP
MAGENTO2_LOCALE_TIMEZONE=Europe/London

### Magento 2 Environment
Configure environment settings

| Variable name  	| Default value  	| Description  	| Sample value  	|
|---	|---	|---	|---	|
MAGENTO2_ENV_EDITION=           # community or enterprise
MAGENTO2_ENV_HOSTNAME=          # e.g. project.localhost.com
MAGENTO2_ENV_WEBROOT=           # e.g. /var/www/html/project/htdocs
MAGENTO2_ENV_MULTITENANT=       # For multisites running Magento 2.0.x only
MAGENTO2_ENV_USEREWRITES=1      # Whether to use URL rewrites (if using Apache)
MAGENTO2_ENV_USESECURITYKEY=1   # Whether to add security key to URLs in admin
MAGENTO2_ENV_SESSIONSAVE=files  # Where to save session files
MAGENTO2_ENV_ENABLECRON=        # Whether to enable Magento 2 cron jobs
MAGENTO2_ENV_CLIUSER=           # The user which owns the files (e.g. administrator)
MAGENTO2_ENV_WEBSERVERGROUP=    # The web server group (e.g. www-data)

### Install command
Extra options to pass to the `bin/magento setup:install` command

| Variable name  	| Default value  	| Description  	| Sample value  	|
|---	|---	|---	|---	|
MAGENTO2_INSTALLCOMMAND_CLEANUPDATABASE= # Set to "--cleanup-database" to enable this

### Static content settings
Themes to exclude from bin/magento setup:static-content:deploy command

| Variable name  	| Default value  	| Description  	| Sample value  	|
|---	|---	|---	|---	|
MAGENTO2_STATICCONTENTDEPLOY_EXCLUDE="true"
MAGENTO2_STATICCONTENTDEPLOY_EXCLUDEDTHEMES=" --exclude-theme=Magento/blank "