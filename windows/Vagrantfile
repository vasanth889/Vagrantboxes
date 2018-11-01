# -*- mode: ruby -*-
# vi: set ft=ruby :

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.


require 'yaml'
require 'fileutils'
require 'uri'
require 'erb'

FILES_PATH = "./files/"
JDK_FILE = "jdk-8u144-windows-x64.exe"
DEFAULT_MOUNT = "C:\\Users\\vagrant\\"

CONFIGURATIONS = YAML.load_file('config.yaml')



Vagrant.configure(2) do |config|
  CONFIGURATIONS['boxes'].each do |box|
  config.vm.box = box['base_box']
  config.vm.host_name = box['output_box']
  config.vm.communicator = "winrm"

  memory = 2048
  cpu = 2

    config.vm.provider :virtualbox do |vb|
      vb.gui = false
      vb.customize ['modifyvm', :id, '--memory', memory]
      vb.customize ['modifyvm', :id, '--cpus', cpu]
    end

    config.vm.network "private_network", ip: box['ip']

    if box['ports']
      box['ports'].each do |port|
        config.vm.network "forwarded_port", guest: port, host: port, guest_ip: box['ip']
      end
    end
    
    if box['resources']
      config.vm.provision "file", source: FILES_PATH + JDK_FILE, destination: DEFAULT_MOUNT + JDK_FILE
      box['resources'].each do |resource|
        source = FILES_PATH + resource
        config.vm.provision "file", source: source, destination: DEFAULT_MOUNT + resource
      end
    end

    if box['tools']
      Arg_1 = box['tools'][0]['git_version']
      Arg_2 = box['tools'][1]['python_version']
      Arg_3 = box['tools'][2]['nodejs_version']
      Arg_4 = box['tools'][3]['maven_version']
    end
    config.vm.provision "shell", path: box["provisioner_script"], args: [JDK_FILE, Arg_1, Arg_2, Arg_3, Arg_4]
  end
end
