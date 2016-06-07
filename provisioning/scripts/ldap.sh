#!/usr/bin/env bash

ROOT_PASS=$1
DOMAIN=$2
DOMAIN_COMPONENTS=(${DOMAIN//./ })
HOST=${DOMAIN_COMPONENTS[0]}
DOMAIN_COMPONENT_STR="dc=$HOST,dc=${DOMAIN_COMPONENTS[1]},dc=${DOMAIN_COMPONENTS[2]},dc=${DOMAIN_COMPONENTS[3]}"
ORGANIZATION=$3
PASS=$4
O=$5
OU=$6
USER=$7
USER_PASS=$8

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
    sed -i -e "s/DOMAIN_COMPONENT_STR_VAL/$DOMAIN_COMPONENT_STR/g; s/DOMAIN_VAL/$DOMAIN/g; s/HOST_VAL/$HOST/g; s/ORGANIZATION_VAL/$ORGANIZATION/g; s/OU_VAL/$OU/g; s/O_VAL/$O/g; s/USER_PASS_VAL/$USER_PASS/g; s/USER_VAL/$USER/g" /home/vagrant/AppsInHD.ldif
    ldapadd -x -D "cn=admin,$DOMAIN_COMPONENT_STR" -w "$PASS" -H ldap:// -f /home/vagrant/AppsInHD.ldif
fi

echo "OpenLDAP Installed"