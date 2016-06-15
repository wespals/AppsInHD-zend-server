#!/usr/bin/env bash

IP=${1}
DOMAIN=${2}

echo "Provisioning base virtual machine..."

echo "America/Chicago" > /etc/timezone
dpkg-reconfigure -f noninteractive tzdata

apt-get update

grep -q -F "${IP} ${DOMAIN}" /etc/hosts || echo "${IP} ${DOMAIN}" >> /etc/hosts

grep -q -F "10.1.0.35 linuxdev" /etc/hosts || echo "10.1.0.35 linuxdev" >> /etc/hosts
