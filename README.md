# AppsInHD-zend-server
Installs and provisions an AppsInHD Zend Server

##Server Build Includes
* Ubuntu 14.04 LTS
* GIT
* MariaDB 10.1
* <a href="http://192.168.33.10:9001" target="_blank">Supervisor</a>
* OpenLDAP
* <a href="http://192.168.33.10:10081/ZendServer/" target="_blank">Zend Server 8.5.3</a>
* PHP 5.6
* <a href="http://192.168.33.10/phpldapadmin/" target="_blank">phpLDAPadmin</a>
* <a href="http://192.168.33.10/phpmyadmin/" target="_blank">phpMyAdmin</a>

##Host Machine Setup
1. Install <a href="https://www.virtualbox.org/wiki/Downloads" target="_blank">Virtual Box</a> (VM Software)
2. Install <a href="https://www.vagrantup.com/downloads.html" target="_blank">Vagrant</a> (VM Provisioning Tool)
3. Install <a href="https://git-scm.com/downloads" target="_blank">GIT</a> client
4. Create new Zend Studio Project from this GIT repository
	* <a href="https://github.com/wespals/AppsInHD-zend-server" target="_blank">AppsInHD-zend-server</a>
5. Guest Machine setup
    * Run `vagrant up` in command prompt
6. Enjoy <a href="https://192.168.33.10:8201/index.html">AppsInHD</a>

###Guest VM user accounts
* Unix/SSH: 
    1. harrisdata
    2. hd_d1_db
* Zend Server: admin
* Zend Server Web API: admin
* Supervisor: admin
* phpLDAPadmin: cn=admin,dc=hdbox,dc=mke,dc=intharrisdata,dc=com
* phpMyAdmin: hd_d1_db
* AppsInHD: HDDemo
