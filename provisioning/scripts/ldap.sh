#!/usr/bin/env bash

ROOT_PASS=$1
DOMAIN=$2
DOMAIN_COMPONENTS=(${DOMAIN//./ })
HOST=${DOMAIN_COMPONENTS[0]}
DOMAIN_COMPONENT_STR="dc=$HOST,dc=${DOMAIN_COMPONENTS[1]},dc=${DOMAIN_COMPONENTS[2]},dc=${DOMAIN_COMPONENTS[3]}"
ORGANIZATION=$3
PASS=$4
WITH_DNS=$5
O=$6
OU=$7
USER=$8
USER_PASS=$9

echo "Provisioning OpenLDAP..."

if [ ! -f /usr/sbin/slapd ]
    then
    echo "Installing OpenLDAP"
    export DEBIAN_FRONTEND=noninteractive
    debconf-set-selections <<< "slapd slapd/root_password password $ROOT_PASS"
    debconf-set-selections <<< "slapd slapd/root_password_again password $ROOT_PASS"
    apt-get install -y slapd ldap-utils

    echo "Configuring OpenLDAP"
    export DEBIAN_FRONTEND=noninteractive
    debconf-set-selections <<< "slapd slapd/no_configuration boolean false"
    debconf-set-selections <<< "slapd slapd/domain string $DOMAIN"
    debconf-set-selections <<< "slapd shared/organization string $ORGANIZATION"
    debconf-set-selections <<< "slapd slapd/password1 password $PASS"
    debconf-set-selections <<< "slapd slapd/password2 password $PASS"
    debconf-set-selections <<< "slapd slapd/backend string HDB"
    debconf-set-selections <<< "slapd slapd/purge_database boolean true"
    debconf-set-selections <<< "slapd slapd/move_old_database boolean true"
    debconf-set-selections <<< "slapd slapd/allow_ldap_v2 boolean false"
    dpkg-reconfigure slapd

    echo "Adding OpenLDAP Entry"
    cp /vagrant/provisioning/config/openldap/AppsInHD.ldif /home/vagrant/AppsInHD.ldif
    sed -i -e "s/DOMAIN_COMPONENT_STR_VAL/$DOMAIN_COMPONENT_STR/; s/DOMAIN_VAL/$DOMAIN/; s/HOST_VAL/$HOST/; s/ORGANIZATION_VAL/$ORGANIZATION/; s/OU_VAL/$OU/; s/O_VAL/$O/; s/USER_PASS_VAL/$USER_PASS/; s/USER_VAL/$USER/" /home/vagrant/AppsInHD.ldif
    ldapadd -x -D "cn=admin,$DOMAIN_COMPONENT_STR" -w "$PASS" -H ldap:// -f /home/vagrant/AppsInHD.ldif
fi

echo "OpenLDAP Installed"

if [ ! -d /etc/phpldapadmin ]
    then
    echo "Installing phpLDAPadmin"
    apt-get install -y phpldapadmin

    echo "Configuring phpLDAPadmin"
    cp /vagrant/provisioning/config/phpldapadmin/config.php /etc/phpldapadmin/config.php
    if [ "$WITH_DNS" = 1 ]
        then
        sed -i -e "s/HOST_VAL/127.0.0.1/; s/DOMAIN_COMPONENT_STR_VAL/$DOMAIN_COMPONENT_STR/" /etc/phpldapadmin/config.php
    else
        sed -i -e "s/HOST_VAL/127.29.160.119/; s/DOMAIN_COMPONENT_STR_VAL/dc=ibmpdp/" /etc/phpldapadmin/config.php
    fi
fi

echo "phpLDAPadmin Installed"