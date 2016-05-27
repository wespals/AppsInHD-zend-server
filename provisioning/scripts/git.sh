#!/usr/bin/env bash

echo "Provisioning Git..."

if [ ! -f /usr/bin/git ]
    then
    echo "Installing Git"
    apt-get install -y git
fi

echo "Git Installed"