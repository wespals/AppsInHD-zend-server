#!/usr/bin/env bash

echo "Provisioning AppsInHD..."

if [ ! -d /var/www/AppsInHD ]
    then
    echo "Cloning AppsInHD"
    #git clone ssh://harrisdata@linuxdev/var/AppsInHD /var/www/AppsInHD
    #git checkout -b development
    #chmod -R www-data:www-data /var/www/AppsInHD
fi

echo "AppsInHD Installed"

echo "Configuring AppsInHD vhost"

    cp /vagrant/provisioning/config/apache2/AppsInHD.conf /etc/apache2/sites-available/AppsInHD.conf
    #a2ensite AppsInHD.conf
    service apache2 restart

echo "Completed AppsInHD vhost"