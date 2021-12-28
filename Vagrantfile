# encoding: utf-8
# -*- mode: ruby -*-
# vi: set ft=ruby :
$attack_type=$1

#----- use YAML config declared in /vagrant/src/target.yml -----#
ATTACK_TYPE = ENV["ATTACK_TYPE"]

require 'yaml'
current_dir = File.dirname(File.expand_path(__FILE__))
config_file = YAML.load_file("#{current_dir}/src/target.yml")
target_config = config_file['configs'][ATTACK_TYPE]
#---------------------------------------------------------------#

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  # Every Vagrant development environment requires a box. You can search for
  # boxes at https://vagrantcloud.com/search.
  N = 0

    config.vm.define target_config['name'] do |target|
      target.vm.hostname = target_config['hostname']
      target.vm.box = target_config['vbox']
      target.vm.network target_config['net_type'], ip: target_config['ip_addr']
      target.vm.provision "shell", path: target_config['script_path']
      if (ATTACK_TYPE == "syn_flood") then
        target.vm.network "forwarded_port", guest: 80, host: 8080
      end

      target.vm.provider "virtualbox" do |vb|
        vb.gui = target_config['gui']
        vb.name = target_config['name']
        vb.memory = target_config['ram']
        vb.cpus = target_config['cpus']
      end
    end

    (0..N).each do |i| 
    config.vm.define "bot#{i}" do |node|
      node.vm.hostname = "BOT#{i}"
      node.vm.box = "ubuntu/bionic64"
      node.vm.network "private_network", ip:"192.168.27.#{10+i}"

      node.vm.provision "file", source:"./tmp_src/go1.17.linux-amd64.tar.gz", destination: "/home/vagrant/tmp_src/go1.17.linux-amd64.tar.gz"
      node.vm.provision "file", source:"./tmp_src/telegraf_1.20.0~rc0-1_amd64.deb", destination: "/home/vagrant/tmp_src/telegraf_1.20.0~rc0-1_amd64.deb"
      node.vm.provision "file", source:"./src/telegraf.conf", destination: "/home/vagrant/telegraf.conf"
      node.vm.provision "file", source:"./python_scripts/dns_amp_attack.py", destination: "/home/vagrant/dns_amp_attack.py"
      node.vm.provision "file", source:"./detect_dns_amp_attack.sh", destination: "/home/vagrant/detect_dns_amp_attack.sh"

      node.vm.provision "shell", path: "./src/tool_setup.sh"
      node.vm.provision "shell", path: "./src/run_telegraf.sh"

      node.vm.provision "file", source:"./traffic_simulation/traffic_data.pcap", destination: "/home/vagrant/traffic_data.pcap"
      node.vm.provision "shell", path: "./traffic_simulation/run_traffic_simulation.sh"
      if (ATTACK_TYPE == "dns_amplification") then
        node.vm.provision "shell", path: "./dns_config/change_resolver.sh"
      end
    end
  end

  # Disable automatic box update checking. If you disable this, then
  # boxes will only be checked for updates when the user runs
  # `vagrant box outdated`. This is not recommended.
  # config.vm.box_check_update = false

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine. In the example below,
  # accessing "localhost:8080" will access port 80 on the guest machine.
  # NOTE: This will enable public access to the opened port
#  config.vm.network "private_network", ip: "192.168.33.10"

  # Create a forwarded port mapping which allows access to a specific port
  # within the machine from a port on the host machine and only allow access
  # via 127.0.0.1 to disable public access
  # config.vm.network "forwarded_port", guest: 80, host: 8080, host_ip: "127.0.0.1"

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"

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

  # Enable provisioning with a shell script. Additional provisioners such as
  # Ansible, Chef, Docker, Puppet and Salt are also available. Please see the
  # documentation for more information about their specific syntax and use.
  # config.vm.provision "shell", inline: <<-SHELL
  #   apt-get update
  #   apt-get install -y apache2
  # SHELL
end

