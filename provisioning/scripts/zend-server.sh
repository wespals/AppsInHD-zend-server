#!/usr/bin/env bash

ZS_VERSION=${1}
PHP_VERSION=${2}
ZS_ADMIN_PASSWORD=${3}
ZS_WEBAPI_KEY_NAME=${4}
ZS_WEBAPI_KEY_SECRET=${5}

echo "Provisioning Zend Server ${ZS_VERSION}..."

if [ ! -f /usr/local/zend/bin/zs-manage ]
    then
    echo "Installing Zend Server ${ZS_VERSION}"
    wget http://downloads.zend.com/zendserver/${ZS_VERSION}/ZendServer-${ZS_VERSION}-RepositoryInstaller-linux.tar.gz
    tar -zxvf ZendServer-${ZS_VERSION}-RepositoryInstaller-linux.tar.gz
    cd ZendServer-RepositoryInstaller-linux/
    ./install_zs.sh ${PHP_VERSION} --automatic
    sed -i -e "s/date.timezone=.*$/date.timezone=America\/Chicago/g" /usr/local/zend/etc/php.ini
fi

echo "Zend Server ${ZS_VERSION} Installed"

if [ ! -f /home/vagrant/zs-bootstrapped ]
    then
    echo "Bootstrap Zend Server ${ZS_VERSION}"
    # Bootstrap Zend server
    # See http://files.zend.com/help/Zend-Server/content/bootstrap-single-server.htm
    /usr/local/zend/bin/zs-manage bootstrap-single-server -p ${ZS_ADMIN_PASSWORD} -a True -r False -N ${ZS_WEBAPI_KEY_NAME} -K ${ZS_WEBAPI_KEY_SECRET}
    /usr/local/zend/bin/zendctl.sh restart
    touch /home/vagrant/zs-bootstrapped
fi

echo "Zend Server ${ZS_VERSION} Bootstrapped"