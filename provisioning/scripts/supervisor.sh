#!/usr/bin/env bash

HD_APPS_DB=$1
HD_APPS_LDAP_ORG=$2

echo "Provisioning Supervisor..."

if [ ! -f /usr/bin/supervisord ]
    then
    echo "Installing Supervisor"
    apt-get install -y supervisor
    echo "Configuring Supervisor"
    cp /vagrant/provisioning/config/supervisor/WebUI.conf /etc/supervisor/conf.d/WebUI.conf
    #cp /vagrant/provisioning/config/apache2/AppsInHD.conf /etc/supervisor/conf.d/AppsInHD.conf
    #sed -i -e "s/HD_APPS_DB/$HD_APPS_DB/; s/HD_APPS_LDAP_ORG/$HD_APPS_LDAP_ORG/" /etc/supervisor/conf.d/AppsInHD.conf
    service supervisor restart
fi

echo "Supervisor Installed"