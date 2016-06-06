#!/usr/bin/env bash

PASS=$1

echo "Provisioning phpMyAdmin..."

if [ ! -d /etc/phpmyadmin ]
    then
    echo "Installing phpMyAdmin"
    #http://stackoverflow.com/questions/30741573/debconf-selections-for-phpmyadmin-unattended-installation-with-no-webserver-inst
    export DEBIAN_FRONTEND=noninteractive
    # disreagard web server setup
    debconf-set-selections <<< "phpmyadmin phpmyadmin/internal/skip-preseed boolean true"
    debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect"
    debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean false"
# for phpmyadmin control user, and webserver
#    debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
#    debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/admin-pass password $PASS"
#    debconf-set-selections <<< "phpmyadmin phpmyadmin/mysql/app-pass password $PASS"
#    debconf-set-selections <<< "phpmyadmin phpmyadmin/app-password-confirm password $PASS"
#    debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
    apt-get install -y phpmyadmin
fi

echo "phpMyAdmin Installed"