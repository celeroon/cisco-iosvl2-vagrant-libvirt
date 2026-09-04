packer {
  required_plugins {
    qemu = {
      version = ">= 1.1.0"
      source  = "github.com/hashicorp/qemu"
    }
  }
}

# No-vagrant variant of cisco-iosvl2.pkr.hcl: boots the IOSvL2 qcow2, configures it
# over the serial console (expect), and leaves the CONFIGURED qcow2 in out_dir/vm_name
# — no Vagrant box post-processing. Import the result as a Proxmox template with:
#   lab template import <out_dir>/<vm_name> cisco-iosvl2-<version>
# Driven by scripts/build-cisco-iosvl2.sh.

variable "version" {
  type    = string
  default = "1.0.0"
}

variable "boot_time" {
  type    = string
  default = "2m"
}

variable "boot_key_interval" {
  type    = string
  default = "50ms"
}

variable "vm_name" {
  default = "cisco-iosvl2"
}

# The disk extracted from Cisco's tgz (single virtioa.qcow2 member).
variable "image_name" {
  type    = string
  default = "virtioa.qcow2"
}

variable "image_path" {
  default = "/var/lib/libvirt/images"
}

variable "qemu_binary" {
  default = "qemu-system-x86_64"
}

variable "telnet_port" {
  default = "52099"
}

variable "out_dir" {
  type    = string
  default = "tmp_out"
}

source "qemu" "cisco-iosvl2" {
  accelerator       = "kvm"
  qemu_binary       = var.qemu_binary
  cpus              = 1
  memory            = "1024"
  disk_image        = true
  format            = "qcow2"
  net_device        = "e1000"
  iso_checksum      = "none"
  iso_url           = "${var.image_path}/${var.image_name}"
  boot_wait         = "${var.boot_time}"
  boot_key_interval = "${var.boot_key_interval}"
  headless          = true
  # No SSH from Packer: the expect script does all provisioning over the serial
  # console, then the shell-local pkill stops qemu so Packer finalises the disk.
  communicator     = "none"
  vm_name          = var.vm_name
  output_directory = "${var.out_dir}"
  shutdown_timeout = "5m"
  qemuargs = [
    ["-nographic"],
    ["-serial", "telnet:127.0.0.1:${var.telnet_port},server,nowait"],
    ["-pidfile", "/tmp/cisco-iosvl2.pid"]
  ]
}

build {
  name = "cisco-iosvl2"

  sources = [
    "qemu.cisco-iosvl2"
  ]

  # Configure the switch over the serial console (telnet_port).
  provisioner "shell-local" {
    inline = [
      "expect cisco_iosvl2_config.exp"
    ]
  }

  # communicator="none" has no shutdown_command, so stop qemu ourselves once the
  # expect run has written startup-config; Packer then keeps output_directory/vm_name.
  provisioner "shell-local" {
    inline = [
      "pkill -f '${var.qemu_binary}.*-name cisco-iosvl2' || true"
    ]
  }
}
