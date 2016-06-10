#!/usr/bin/env bash

HD_DB=${1}
HD_ENV=${2}
APP_ROOT=${3}
ADMIN_USER=${4}
ADMIN_PASS=${5}

echo "Provisioning Supervisor..."

if [ ! -f /usr/bin/supervisord ]
    then
    echo "Installing Supervisor"
    apt-get install -y supervisor
    echo "Configuring Supervisor"
    cp /vagrant/provisioning/config/supervisor/supervisord.conf /etc/supervisor/supervisord.conf
    cp /vagrant/provisioning/config/supervisor/WebUI.conf /etc/supervisor/conf.d/WebUI.conf
    sed -i -e "s/ADMIN_USER_VAL/${ADMIN_USER}/g; s/ADMIN_PASS_VAL/${ADMIN_PASS}/g" /etc/supervisor/conf.d/WebUI.conf
    cp /vagrant/provisioning/config/supervisor/AppsInHD.conf /etc/supervisor/conf.d/AppsInHD.conf
    sed -i -e "s/HD_DB_VAL/${HD_DB}/g; s/HD_ENV_VAL/${HD_ENV}/g; s#APP_ROOT_VAL#${APP_ROOT}#g" /etc/supervisor/conf.d/AppsInHD.conf
    service supervisor restart

    if [ ! -f /etc/logrotate.d/supervisor ]
        then
        echo "Installing Supervisor log rotation"
        cp /vagrant/provisioning/config/supervisor/logrotate /etc/logrotate.d/supervisor
    fi

fi

echo "Supervisor Installed"