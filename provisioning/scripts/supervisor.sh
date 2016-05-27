#!/usr/bin/env bash

echo "Provisioning Supervisor..."

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