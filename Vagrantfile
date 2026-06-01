# -*- mode: ruby -*-
# vi: set ft=ruby :

VAGRANTFILE_API_VERSION = "2"

# Read .env file for git config
if File.exist?(".env")
  File.foreach(".env") do |line|
    line.strip!
    next if line.empty? || line.start_with?("#")
    key, value = line.split("=", 2)
    ENV[key] = value
  end
end

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|

  # Every Vagrant virtual environment requires a box to build off of.
  config.vm.box = "bento/ubuntu-24.04"

  # config.vm.network "forwarded_port", guest: 80, host: 3000
  # config.vm.network :private_network, ip: "192.168.56.11"

  # provider stuff here
  # config.vm.provider :vmware_desktop do |vmware|
  #   vmware.vmx["ethernet0.pcislotnumber"] = "160"
  #   vmware.vmx["ethernet1.pcislotnumber"] = "224"
  # end

  # provider stuff here
  # config.vm.provider "virtualbox" do |v|
  #   v.name = "vagrant_agent"
  #   v.memory = 4096
  #   v.cpus = 2
  #   v.gui = false
  #   v.customize(["modifyvm", :id, "--audio", "none"])
  #   v.customize(["modifyvm", :id, "--usb", "off"])
  # end

  # mount ~/.claude and ~/.codex to keep sessions across reboots
  config.vm.synced_folder "~/.claude", "/home/vagrant/.claude"
  config.vm.synced_folder "~/.codex", "/home/vagrant/.codex"
  # mount a .claude.json file; allows us to keep auth across reboots
  # make this dir locally before running
  # optionally, if you've run claude code locally, mount your local .claude.json instead
  config.vm.synced_folder "~/.claude_for_vagrant", "/home/vagrant", type: "rsync", rsync__args: ["-r", "--include=.claude.json", "--exclude=*"]
  # mount project folders here
  # config.vm.synced_folder "../my-project/", "/projects/my-project/"

  config.vm.provision "shell" do |s|
    s.path = "provision.sh"
    s.env = {
      "GIT_NAME"  => ENV["GIT_NAME"],
      "GIT_EMAIL" => ENV["GIT_EMAIL"]
    }
  end
end
