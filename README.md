# AppsInHD-zend-server
Installs and provisions an AppsInHD Zend Server

##Server Build Includes
* Ubuntu 14.04 LTS
* Zend Server 8.5.3
* PHP 5.6
* MariaDB 10.1
* Supervisor
* GIT

##Host Machine Setup
1. Install Virtual Box (VM Software)
    * Download https://www.virtualbox.org/wiki/Downloads
2. Install Vagrant (VM Configuration Tool)
    * Download https://www.vagrantup.com/downloads.html
3. Install GIT client
    * Download https://git-scm.com/downloads
4. Create new Zend Studio Project from this GIT repository
	* https://github.com/wespals/AppsInHD-zend-server
5. Guest Machine setup
    * Run `vagrant up` in command prompt
6. Enjoy http://192.168.33.10:10081/ZendServer/
