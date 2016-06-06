#!/usr/bin/env bash

VERSION=$1
PASS=$2

echo "Provisioning MariaDB $VERSION..."

if [ ! -f /usr/bin/mysql ]
    then
    echo "Installing MariaDB $VERSION"
    apt-get install -y software-properties-common
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
    add-apt-repository "deb http://ftp.osuosl.org/pub/mariadb/repo/$VERSION/ubuntu trusty main"
    apt-get update
    export DEBIAN_FRONTEND=noninteractive
    debconf-set-selections <<< "mariadb-server-$VERSION mysql-server/root_password password $PASS"
    debconf-set-selections <<< "mariadb-server-$VERSION mysql-server/root_password_again password $PASS"
    apt-get install -y mariadb-server
fi

echo "MariaDB $VERSION Installed"

if [ ! -d /etc/phpmyadmin ]
    then
    echo "Installing phpMyAdmin"
    #http://gercogandia.blogspot.com/2012/11/automatic-unattended-install-of.html
    export DEBIAN_FRONTEND=noninteractive
    debconf-set-selections <<< "phpmyadmin phpmyadmin/reconfigure-webserver multiselect apache2"
    debconf-set-selections <<< "phpmyadmin phpmyadmin/dbconfig-install boolean true"
    apt-get install -y phpmyadmin
fi

echo "phpMyAdmin Installed"