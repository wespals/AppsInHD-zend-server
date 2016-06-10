#!/usr/bin/env bash

PASS=${1}

echo "Provisioning phpMyAdmin..."

if [ ! -d /etc/phpmyadmin ]
    then
    echo "Installing phpMyAdmin"
    export DEBIAN_FRONTEND=noninteractive
    debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
    debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password ${PASS}"
    debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password ${PASS}"
    debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password ${PASS}"
    debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
    apt-get install -y phpmyadmin
fi

echo "phpMyAdmin Installed"