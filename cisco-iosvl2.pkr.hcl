packer {
  required_plugins {
    vagrant = {
      version = ">= 1.0.0"
      source  = "github.com/hashicorp/vagrant"
    }
    qemu = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

variable "version" {
  type    = string
  default = "1.0.0"
}

variable "vm_name" {
  default = "cisco-iosvl2"
}

variable "qcow2_path" {
  default = "/var/lib/libvirt/images/cisco-iosvl2.qcow2"
}

variable "qemu_binary" {
  default = "qemu-system-x86_64"
}

variable "telnet_port" {
  default = "52099"
}

source "qemu" "cisco-iosvl2" {
  vm_name          = var.vm_name
  iso_url          = var.qcow2_path
  iso_checksum     = "none"
  disk_image       = true
  format           = "qcow2"
  output_directory = "build/output"
  accelerator      = "kvm"
  cpus             = 1
  memory           = "4096"
  headless         = true
  qemu_binary      = var.qemu_binary
  net_device       = "e1000"
  shutdown_timeout = "5m"

  qemuargs = [
    ["-cdrom", "/var/lib/libvirt/images/cisco-iosvl2.qcow2"],
    ["-nographic"],
    ["-serial", "telnet:127.0.0.1:${var.telnet_port},server,nowait"],
    ["-boot", "d"],
    ["-pidfile", "/tmp/cisco-iosvl2.pid"]
  ]

  boot_wait = "1m"
  communicator = "none"
}

build {
  name = "cisco-iosvl2"

  sources = [
    "qemu.cisco-iosvl2"
  ]

  # First shell script: Configuring the VM
  provisioner "shell-local" {
    inline = [
      "expect cisco_iosxe_config.exp"
    ]
  }

  # Second shell script: Terminate the QEMU process
  provisioner "shell-local" {
    inline = [
      "pkill -f '/usr/bin/qemu-system-x86_64.*-name cisco-iosvl2'"
    ]
  }

  post-processor "vagrant" {
    output = "builds/cisco-iosvl2-${var.version}.box"
  }
}
