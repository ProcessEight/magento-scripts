# Magento 2 Deployment

## Install

To use the scripts to install a new Magento 2 instance:

```bash
$ mkdir projectname
$ cd projectname
$ ln -s /var/www/html/projectname/install install
$ cp install/config.env.sample config.env
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
$ ln -s /var/www/html/projectname/update update
$ cp update/config.env.sample config.env
```

Now update the `config.env` file, then:

```bash
$ cd projectname
$ ./update/05-run-all-steps.sh
```
