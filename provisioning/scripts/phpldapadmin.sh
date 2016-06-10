#!/usr/bin/env bash

DOMAIN=${1}
DOMAIN_COMPONENTS=(${DOMAIN//./ })
HOST=${DOMAIN_COMPONENTS[0]}
DOMAIN_COMPONENT_STR="dc=${HOST},dc=${DOMAIN_COMPONENTS[1]},dc=${DOMAIN_COMPONENTS[2]},dc=${DOMAIN_COMPONENTS[3]}"
WITH_DNS=${2}

echo "Provisioning phpLDAPadmin..."

if [ ! -d /etc/phpldapadmin ]
    then
    echo "Installing phpLDAPadmin"
    apt-get install -y phpldapadmin

    echo "Configuring phpLDAPadmin"
    cp /vagrant/provisioning/config/phpldapadmin/config.php /etc/phpldapadmin/config.php
    if [ "${WITH_DNS}" = 1 ]
        then
        sed -i -e "s/HOST_VAL/127.0.0.1/g; s/DOMAIN_COMPONENT_STR_VAL/${DOMAIN_COMPONENT_STR}/g" /etc/phpldapadmin/config.php
    else
        sed -i -e "s/HOST_VAL/127.29.160.119/g; s/DOMAIN_COMPONENT_STR_VAL/dc=ibmpdp/g" /etc/phpldapadmin/config.php
    fi
fi

echo "phpLDAPadmin Installed"