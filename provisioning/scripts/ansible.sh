#!/usr/bin/env bash

echo "Provisioning Ansible..."

if [ ! -f /usr/bin/ansible-playbook ]
    then
    echo "Installing Ansible"
    apt-get install -y software-properties-common
    apt-add-repository ppa:ansible/ansible
    apt-get update
    apt-get install -y ansible
fi

echo "Ansible Installed"