# Magento 2 Deployment

## First-time Setup

```bash
git clone git@bitbucket.org:purenetgit/magento2-deployment.git
```

## Install

To use the scripts to install a new Magento 2 instance:

```bash
$ mkdir projectname
$ cd projectname
$ ln -s /var/www/html/magento2-deployment/install install
$ cp config.env.sample config.env
```

Now update the `config.env` file, then:

```bash
$ cd /var/www/html/projectname
$ ./install/05-run-all-steps.sh
```

## Update

To use the scripts to update an existing Magento 2 instance:

```bash
$ cd /var/www/html/projectname
$ ln -s /var/www/html/magento2-deployment/update update
$ cp config.env.sample config.env
```

Now update the `config.env` file, then:

```bash
$ cd /var/www/html/projectname
$ ./update/05-run-all-steps.sh
```
