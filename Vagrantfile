# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure(2) do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://atlas.hashicorp.com/search.
  config.vm.box = "ubuntu/trusty64"
  config.vm.hostname = "hdbox"

  # HarrisData configuration vars
  hd_user = "harrisdata"
  hd_pass = "hd13555"
  hd_env = "D1"
  hd_db_name = "hd_" + hd_env.downcase + "_db"
  hd_fqdn = config.vm.hostname + ".mke.intharrisdata.com"
  hd_ldap_o = hd_env
  hd_ldap_ou = "G" + hd_ldap_o
  hd_app_user = "HDDemo"
  hd_app_root = "/home/"+ hd_user + "/AppsInHD/"

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # config.vm.network "forwarded_port", guest: 80, host: 8080

  # HTTP and Zend Server ports
  config.vm.network "forwarded_port", guest: 80, host: 8083
  config.vm.network "forwarded_port", guest: 443, host: 8443
  config.vm.network "forwarded_port", guest: 10080, host: 11081
  config.vm.network "forwarded_port", guest: 10081, host: 11082
  config.vm.network "forwarded_port", guest: 10082, host: 11083

  # Supervisor WebUI port
  config.vm.network "forwarded_port", guest: 9001, host: 19001

  # AppsInHD ports
  config.vm.network "forwarded_port", guest: 8201, host: 18201
  config.vm.network "forwarded_port", guest: 8202, host: 18202
  config.vm.network "forwarded_port", guest: 8203, host: 18203
  config.vm.network "forwarded_port", guest: 8204, host: 18204
  config.vm.network "forwarded_port", guest: 8205, host: 18205
  config.vm.network "forwarded_port", guest: 8206, host: 18206
  config.vm.network "forwarded_port", guest: 8207, host: 18207

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  config.vm.network "private_network", ip: "192.168.33.10"

  # Create a public network, which generally matched to bridged network.
  # Bridged networks make the machine appear as another physical device on
  # your network.
  # config.vm.network "public_network"

  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  # Example for VirtualBox:
  #
  # config.vm.provider "virtualbox" do |vb|
  #   # Display the VirtualBox GUI when booting the machine
  #   vb.gui = true
  #
  #   # Customize the amount of memory on the VM:
  #   vb.memory = "1024"
  # end
  #
  # View the documentation for the provider you are using for more
  # information on available options.
  config.vm.provider "virtualbox" do |vb|
    vb.memory = "2048"
    vb.cpus = 2
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
  end

  # Define a Vagrant Push strategy for pushing to Atlas. Other push strategies
  # such as FTP and Heroku are also available. See the documentation at
  # https://docs.vagrantup.com/v2/push/atlas.html for more information.
  # config.push.define "atlas" do |push|
  #   push.app = "YOUR_ATLAS_USERNAME/YOUR_APPLICATION_NAME"
  # end

  # Enable provisioning with a shell script. Additional provisioners such as
  # Puppet, Chef, Ansible, Salt, and Docker are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   sudo apt-get update
  #   sudo apt-get install -y apache2
  # SHELL

  # Provision Base
  config.vm.provision "shell", path: "provisioning/scripts/base.sh", args: ["192.168.33.10", hd_fqdn]

  # Provision Ansible
  #config.vm.provision "shell", path: "provisioning/scripts/ansible.sh"

  # Provision Git
  config.vm.provision "shell", path: "provisioning/scripts/git.sh"

  # Provision MariaDB
  config.vm.provision "shell", path: "provisioning/scripts/mariadb.sh", args: ["10.1", hd_pass]

  # Provision Zend Server
  config.vm.provision "shell", path: "provisioning/scripts/zend-server.sh", args: ["8.5.3", "5.6", hd_pass, "admin", "aaaabbbbccccddddeeeeffffgggghhhhiiiijjjjkkkkllllmmmmnnnnoooopppp"]

  # Provision OpenLDAP
  config.vm.provision "shell", path: "provisioning/scripts/ldap.sh", args: [hd_pass, hd_fqdn, "HarrisData", hd_pass, hd_ldap_o, hd_ldap_ou, hd_app_user, hd_pass, hd_db_name]

  # Provision AppsInHD
  config.vm.provision "shell", path: "provisioning/scripts/apps-in-hd.sh", args: ["development", hd_env, hd_db_name, "192.168.33.10", hd_fqdn, hd_ldap_o, hd_ldap_ou, hd_user, hd_pass, hd_app_user, hd_app_root]

  # Provision Supervisor
  config.vm.provision "shell", path: "provisioning/scripts/supervisor.sh", args: [hd_db_name, hd_env, hd_app_root, "admin", hd_pass]

  # Provision phpLDAPadmin
  config.vm.provision "shell", path: "provisioning/scripts/phpldapadmin.sh", args: [hd_fqdn, 1]

  # Provision phpMyAdmin
  config.vm.provision "shell", path: "provisioning/scripts/phpmyadmin.sh", args: [hd_pass]

  # Provision Markdown
  config.vm.provision "shell", path: "provisioning/scripts/markdown.sh"

  # Provision complete
  config.vm.provision "shell", inline: "markdown /vagrant/README.md > /var/www/html/index.html"
  config.vm.provision "shell", inline: "echo Enjoy http://192.168.33.10/"

  # Run guest machine local provisioner
  # See https://www.vagrantup.com/docs/provisioning/ansible_local.html
  #config.vm.provision "ansible_local" do |ansible|
  #  ansible.playbook = "/vagrant/provisioning/playbook.yml"
  #end
  # currently broken
  # See https://github.com/mitchellh/vagrant/issues/6740

  # Maybe run ansible playbook in the VM, cause lack of Windows support
  # See http://www.thisprogrammingthing.com/2015/using-ansible-with-vagrant-and-windows/
  #config.vm.provision "shell", path: "/path/to/ansible/provision.sh"

end
