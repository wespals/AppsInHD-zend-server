#!/usr/bin/env bash

IP=$1
DOMAIN=$2

echo "Provisioning base virtual machine..."

apt-get update

grep -q -F "${IP} ${DOMAIN}" /etc/hosts || echo "${IP} ${DOMAIN}" >> /etc/hosts