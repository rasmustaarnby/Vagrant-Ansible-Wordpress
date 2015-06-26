# -*- mode: ruby -*-
# vi: set ft=ruby :

require_relative './key_authorization'

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"
vagrant_dir = File.expand_path(File.dirname(__FILE__))

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  config.vm.box = "ubuntu/trusty64"
  authorize_key_for_root config, '~/.ssh/id_dsa.pub', '~/.ssh/id_rsa.pub'
  config.vm.network :private_network, ip: "192.168.50.50"
  config.vm.hostname = "vagrant"

  # config.vm.provision "ansible" do |ansible|
  #   ansible.verbose = "vvvv"
  #   ansible.playbook = "provision/vagrant.yml"
  #   ansible.inventory_path = "provision/vagrant-inventory"
  #   ansible.host_key_checking = "true"
  #   ansible.limit = "all"
  #   ansible.extra_vars = { ansible_ssh_user: 'vagrant' }
  # end

  config.vm.provision :shell,
  :keep_color => true,
  :inline => "export PYTHONUNBUFFERED=1 && export ANSIBLE_FORCE_COLOR=1 && cd /vagrant/provision && ./init.sh"

  # Store the current version of Vagrant for use in conditionals when dealing
  # with possible backward compatible issues.
  vagrant_version = Vagrant::VERSION.sub(/^v/, '')

  # Configuration options for the VirtualBox provider.
  config.vm.provider :virtualbox do |vb|
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end

  # /srv/config/
  #
  # If a server-conf directory exists in the same directory as your Vagrantfile,
  # a mapped directory inside the VM will be created that contains these files.
  # This directory is currently used to maintain various config files for php and
  # nginx as well as any pre-existing database files.
  config.vm.synced_folder "config/", "/srv/config"

  # /srv/www/
  #
  # If a www directory exists in the same directory as your Vagrantfile, a mapped directory
  # inside the VM will be created that acts as the default location for nginx sites. Put all
  # of your project files here that you want to access through the web server
  if vagrant_version >= "1.3.0"
    config.vm.synced_folder "www/", "/srv/www/", :owner => "www-data", :mount_options => [ "dmode=775", "fmode=774" ]
  else
    config.vm.synced_folder "www/", "/srv/www/", :owner => "www-data", :extra => 'dmode=775,fmode=774'
  end

  # /srv/database/
  #
  # If a database directory exists in the same directory as your Vagrantfile,
  # a mapped directory inside the VM will be created that contains these files.
  # This directory is used to maintain default database scripts as well as backed
  # up mysql dumps (SQL files) that are to be imported automatically on vagrant up
  config.vm.synced_folder "database/", "/srv/database"

  config.vm.synced_folder ".", "/vagrant", owner:"www-data", group:"www-data", mount_options:["dmode=775", "fmode=775"]

  # SSH Agent Forwarding
  #
  # Enable agent forwarding on vagrant ssh commands. This allows you to use ssh keys
  # on your host machine inside the guest. See the manual for `ssh-add`.
  config.ssh.forward_agent = true
  config.ssh.shell = "bash -c 'BASH_ENV=/etc/profile exec bash'"
  # config.vm.network :forwarded_port, guest: 35735, host: 35735



  # Local Machine Hosts
  #
  # If the Vagrant plugin hostsupdater (https://github.com/cogitatio/vagrant-hostsupdater) is
  # installed, the following will automatically configure your local machine's hosts file to
  # be aware of the domains specified below. Watch the provisioning script as you may need to
  # enter a password for Vagrant to access your hosts file.
  #
  # By default, we'll include the domains set up by VVV through the vvv-hosts file
  # located in the www/ directory.
  #
  # Other domains can be automatically added by including a vvv-hosts file containing
  # individual domains separated by whitespace in subdirectories of www/.
  if defined?(VagrantPlugins::HostsUpdater)
    # Recursively fetch the paths to all vvv-hosts files under the www/ directory.
    paths = Dir[File.join(vagrant_dir, 'www', '**', 'vvv-hosts')]

    # Parse the found vvv-hosts files for host names.
    hosts = paths.map do |path|
      # Read line from file and remove line breaks
      lines = File.readlines(path).map(&:chomp)
      # Filter out comments starting with "#"
      lines.grep(/\A[^#]/)
    end.flatten.uniq # Remove duplicate entries

    # Pass the found host names to the hostsupdater plugin so it can perform magic.
    config.hostsupdater.aliases = hosts
    config.hostsupdater.remove_on_suspend = true
  end

  # Vagrant Triggers
  #
  # If the vagrant-triggers plugin is installed, we can run various scripts on Vagrant
  # state changes like `vagrant up`, `vagrant halt`, `vagrant suspend`, and `vagrant destroy`
  #
  # These scripts are run on the host machine, so we use `vagrant ssh` to tunnel back
  # into the VM and execute things. By default, each of these scripts calls db_backup
  # to create backups of all current databases. This can be overridden with custom
  # scripting. See the individual files in config/homebin/ for details.
  # if defined? VagrantPlugins::Triggers
  #   config.trigger.before :halt, :stdout => true do
  #     run "vagrant ssh -c 'vagrant_halt'"
  #   end
  #   config.trigger.before :suspend, :stdout => true do
  #     run "vagrant ssh -c 'vagrant_suspend'"
  #   end
  #   config.trigger.before :destroy, :stdout => true do
  #     run "vagrant ssh -c 'vagrant_destroy'"
  #   end
  # end
end
