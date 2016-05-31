#!/usr/bin/env bash

ROOT_PASS=$1
DOMAIN=$2
DOMAIN_PCS=(${DOMAIN//./ })
DOMAIN_CTL="dc=${DOMAIN_PCS[0]},dc=${DOMAIN_PCS[1]},dc=${DOMAIN_PCS[2]},dc=${DOMAIN_PCS[3]}"
HOST=${DOMAIN_PCS[0]}
ORGANIZATION=$3
PASS=$4
WITH_DNS=$5
DEFAULT_O=$6
DEFAULT_OU=$7
DEFAULT_USER=$8
DEFAULT_USER_PASS=$9

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
    debconf-set-selections <<< "slapd slapd/organization string $ORGANIZATION"
    debconf-set-selections <<< "slapd slapd/password1 password $PASS"
    debconf-set-selections <<< "slapd slapd/password2 password $PASS"
    debconf-set-selections <<< "slapd slapd/backend string HDB"
    debconf-set-selections <<< "slapd slapd/purge_database boolean true"
    debconf-set-selections <<< "slapd slapd/move_old_database boolean true"
    debconf-set-selections <<< "slapd slapd/allow_ldap_v2 boolean false"
    dpkg-reconfigure slapd

    echo "Adding OpenLDAP Entry"
    cp /vagrant/provisioning/config/openldap/AppsInHD.ldif /home/vagrant/AppsInHD.ldif
    sed -i -e "s/DOMAIN_CTL/$DOMAIN_CTL/; s/DOMAIN/$DOMAIN/; s/HOST/$HOST/; s/LDAP_ORGANIZATION/$ORGANIZATION/; s/DEFAULT_OU/$DEFAULT_OU/; s/DEFAULT_O/$DEFAULT_O/; s/DEFAULT_USER_PASS/$DEFAULT_USER_PASS/; s/DEFAULT_USER/$DEFAULT_USER/" /home/vagrant/AppsInHD.ldif
    ldapadd -x -D "cn=admin,$DOMAIN_CTL" -w "$PASS" -H ldap:// -f /home/vagrant/AppsInHD.ldif
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
        sed -i -e "s/DOMAIN_IP/127.0.0.1/; s/DOMAIN_CTL/$DOMAIN_CTL/" /etc/phpldapadmin/config.php
    else
        sed -i -e "s/DOMAIN_IP/127.29.160.119/; s/DOMAIN_CTL/dc=ibmpdp/" /etc/phpldapadmin/config.php
    fi
fi

echo "phpLDAPadmin Installed"