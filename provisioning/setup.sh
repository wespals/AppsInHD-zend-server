#!/bin/bash

ZS_VERSION=$1
PHP_VERSION=$2
ZS_ADMIN_PASSWORD=$3
ZS_WEBAPI_KEY_NAME=$4
ZS_WEBAPI_KEY_SECRET=$5
DB_VERSION=$6
DB_PASS=$7

echo "Provisioning virtual machine..."

#if [ ! -f /usr/bin/ansible-playbook ]
#    then
#    echo "Installing Ansible"
#    apt-get install -y software-properties-common
#    apt-add-repository ppa:ansible/ansible
#    apt-get update
#    apt-get install -y ansible
#fi
#echo "Ansible Installed"

if [ ! -f /usr/local/zend/bin/zs-manage ]
    then
    echo "Installing Zend Server $ZS_VERSION"
    wget http://downloads.zend.com/zendserver/$ZS_VERSION/ZendServer-$ZS_VERSION-RepositoryInstaller-linux.tar.gz
    tar -zxvf ZendServer-$ZS_VERSION-RepositoryInstaller-linux.tar.gz
    cd ZendServer-RepositoryInstaller-linux/
    ./install_zs.sh $PHP_VERSION --automatic
fi
echo "Zend Server $ZS_VERSION Installed"

if [ ! -f /home/vagrant/zs-bootstrapped ]
    then
    echo "Bootstrap Zend Server $ZS_VERSION"
    # Bootstrap Zend server
    # See http://files.zend.com/help/Zend-Server/content/bootstrap-single-server.htm
    /usr/local/zend/bin/zs-manage bootstrap-single-server -p $ZS_ADMIN_PASSWORD -a True -r False -N $ZS_WEBAPI_KEY_NAME -K $ZS_WEBAPI_KEY_SECRET
    /usr/local/zend/bin/zendctl.sh restart
    touch /home/vagrant/zs-bootstrapped
fi
echo "Zend Server $ZS_VERSION Bootstrapped"

if [ ! -f /usr/bin/mysql ]
    then
    echo "Installing MariaDB"
    apt-get update
    apt-get install -y software-properties-common
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
    add-apt-repository "deb [arch=amd64,i386] http://ftp.utexas.edu/mariadb/repo/$DB_VERSION/ubuntu trusty main"
    apt-get update
    export DEBIAN_FRONTEND=noninteractive
    debconf-set-selections <<< "mariadb-server-$DB_VERSION mysql-server/root_password password $DB_PASS"
    debconf-set-selections <<< "mariadb-server-$DB_VERSION mysql-server/root_password_again password $DB_PASS"
    apt-get install -y mariadb-server
fi
echo "MariaDB Installed"

if [ ! -f /usr/bin/supervisord ]
    then
    echo "Installing Supervisor"
    apt-get install -y supervisor
    echo "Configuring Supervisor"
    cp /vagrant/provisioning/config/supervisor/WebUI.conf /etc/supervisor/conf.d/WebUI.conf
    #cp /vagrant/provisioning/config/apache2/AppsInHD.conf /etc/supervisor/conf.d/AppsInHD.conf
    service supervisor restart
fi
echo "Supervisor Installed"

if [ ! -f /usr/bin/git ]
    then
    echo "Installing Git"
    apt-get install -y git
fi
echo "Git Installed"

if [ ! -d /var/www/AppsInHD ]
    then
    echo "Cloning AppsInHD"
    #git clone ssh://harrisdata@linuxdev/var/AppsInHD /var/www/AppsInHD
    #git checkout -b development
    #chmod -R www-data:www-data /var/www/AppsInHD
fi
echo "AppsInHD Installed"

echo "Configuring AppsInHD vhost"
    cp /vagrant/provisioning/config/apache2/AppsInHD.conf /etc/apache2/sites-available/AppsInHD.conf
    #a2ensite AppsInHD.conf
    service apache2 restart
echo "Completed AppsInHD vhost"