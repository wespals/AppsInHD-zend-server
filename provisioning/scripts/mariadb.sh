#!/usr/bin/env bash

DB_VERSION=$1
DB_PASS=$2

echo "Provisioning MariaDB $DB_VERSION..."

if [ ! -f /usr/bin/mysql ]
    then
    echo "Installing MariaDB $DB_VERSION"
    apt-get install -y software-properties-common
    apt-key adv --recv-keys --keyserver hkp://keyserver.ubuntu.com:80 0xcbcb082a1bb943db
    add-apt-repository "deb [arch=amd64,i386] http://ftp.utexas.edu/mariadb/repo/$DB_VERSION/ubuntu trusty main"
    apt-get update
    export DEBIAN_FRONTEND=noninteractive
    debconf-set-selections <<< "mariadb-server-$DB_VERSION mysql-server/root_password password $DB_PASS"
    debconf-set-selections <<< "mariadb-server-$DB_VERSION mysql-server/root_password_again password $DB_PASS"
    apt-get install -y mariadb-server
fi

echo "MariaDB $DB_VERSION Installed"