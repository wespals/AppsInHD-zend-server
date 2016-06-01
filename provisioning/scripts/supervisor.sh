#!/usr/bin/env bash

HD_DB=$1
HD_ENV=$2
ADMIN_USER=$3
ADMIN_PASS=$4

echo "Provisioning Supervisor..."

if [ ! -f /usr/bin/supervisord ]
    then
    echo "Installing Supervisor"
    apt-get install -y supervisor
    echo "Configuring Supervisor"
    cp /vagrant/provisioning/config/supervisor/WebUI.conf /etc/supervisor/conf.d/WebUI.conf
    sed -i -e "s/ADMIN_USER_VAL/$ADMIN_USER/; s/ADMIN_PASS_VAL/$ADMIN_PASS/" /etc/supervisor/conf.d/WebUI.conf
    #cp /vagrant/provisioning/config/apache2/AppsInHD.conf /etc/supervisor/conf.d/AppsInHD.conf
    #sed -i -e "s/HD_DB_VAL/$HD_DB/; s/HD_ENV_VAL/$HD_ENV/" /etc/supervisor/conf.d/AppsInHD.conf
    service supervisor restart
fi

echo "Supervisor Installed"