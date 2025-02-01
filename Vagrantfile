Vagrant.configure("2") do |config|
  config.vm.define "sw1" do |node|
    node.vm.guest = :freebsd
    node.vm.box = "cisco-iosvl2"
    node.vm.box_version = "2025"
    node.nfs.verify_installed = false
    node.vm.synced_folder ".", "/vagrant", disabled: true
    node.vm.allow_hosts_modification = false

    node.vm.provider :libvirt do |libvirt|
      libvirt.management_network_name = 'default'
      # libvirt.management_network_address = "192.168.0.0/24"
      # libvirt.management_network_mac = "52:54:00:00:01:25"
      libvirt.management_network_keep = true
      libvirt.memory = 1024
      libvirt.cpus = 1
      libvirt.nic_model_type = "e1000"
      libvirt.graphics_type = "none"
      libvirt.video_type = "cirrus"
      libvirt.disk_bus = "virtio"
    end

    # gi1/0/1
    node.vm.network "public_network", 
      bridge: "virbr2",
      type: "bridge",
      dev: "virbr2",
      auto_config: false
    
    # gi1/0/2
    node.vm.network :private_network,
      :libvirt__iface_name => "g0/1",
      :libvirt__tunnel_type => "udp",
      :libvirt__tunnel_local_ip => "127.1.1.1",
      :libvirt__tunnel_local_port => "10001",
      :libvirt__tunnel_ip => "127.1.1.2",
      :libvirt__tunnel_port => "10001",
      auto_config: false

    node.ssh.insert_key = false
    config.ssh.username = "vagrant"
    config.ssh.password = "vagrant"
  end
end
