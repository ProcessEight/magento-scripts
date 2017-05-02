# Magento 2 Deployment

## First-time Setup

```bash
git clone git@bitbucket.org:purenetgit/magento2-deployment.git
```

## Install locally

To use the scripts to install a new Magento 2 instance:

```bash
$ mkdir projectname
$ cd projectname
$ ln -s /var/www/html/magento2-deployment/install install
$ cp config-m2.env.sample config-m2.env
```

Now update the `config-m2.env` file, then:

```bash
$ cd /var/www/html/projectname
$ ./install/05-run-all-steps.sh
```

## Update locally

To use the scripts to update an existing Magento 2 instance:

```bash
$ cd /var/www/html/projectname/scripts
$ ln -s /var/www/html/magento2-deployment/update update
$ cp config-m2.env.sample config-m2.env
```

Now update the `config-m2.env` file, then:

```bash
$ cd /var/www/html/projectname
$ ./update/05-run-all-steps.sh
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
