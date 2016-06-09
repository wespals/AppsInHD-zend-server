#!/usr/bin/env bash

echo "Provisioning Markdown..."

if [ ! -f /usr/bin/markdown ]
    then
    echo "Installing Markdown"
    apt-get install -y markdown
fi

echo "Markdown Installed"