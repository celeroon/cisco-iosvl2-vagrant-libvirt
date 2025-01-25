Vagrant.configure("2") do |config|
  # Define the VM named 'sw1'
  config.vm.define "sw1" do |node|
    # Specify the Vagrant box to use
    node.vm.box = "cisco-iosvl2"

    # Prevent Vagrant from inserting its default SSH key
    node.ssh.insert_key = false

    # Disable the default shared folder synchronization
    node.vm.synced_folder ".", "/vagrant", disabled: true

    # Configure the primary network interface and VM resources
    node.vm.provider :libvirt do |domain|
      # Use the 'default' libvirt management network
      domain.management_network_name = 'default'

      # Set the memory allocated to the VM (in MB)
      domain.memory = 512

      # Set the number of CPUs allocated to the VM
      domain.cpus = 1

      # Use the e1000 NIC model for the primary interface
      domain.nic_model_type = "e1000"

      # Disable graphical display for the VM
      domain.graphics_type = "none"

      # Set the video type (required even if graphics are disabled)
      domain.video_type = "cirrus"

      # Use virtio as the disk bus for better performance
      domain.disk_bus = "virtio"
    end

    # Add an additional private network interface for the VM
    node.vm.network :private_network,
      :libvirt__iface_name => "g0/1",               # Set the name of the interface in libvirt
      :libvirt__tunnel_type => "udp",              # Specify tunnel type (UDP in this case)
      :libvirt__tunnel_local_ip => "127.1.1.1",    # Set the local IP for the tunnel
      :libvirt__tunnel_local_port => "10001",      # Set the local port for the tunnel
      :libvirt__tunnel_ip => "127.1.2.1",          # Set the remote tunnel IP
      :libvirt__tunnel_port => "10001",            # Set the remote tunnel port
      auto_config: false                           # Prevent Vagrant from automatically configuring the interface

    # Set SSH credentials for the VM
    config.ssh.username = "vagrant"
    config.ssh.password = "vagrant"
  end
end
