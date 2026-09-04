# cisco-iosvl2-vagrant-libvirt

Packer builds for a Cisco **IOSvL2** (`vios_l2`) switch image — either a Vagrant box
for libvirt, or a bare pre-configured **qcow2** for KVM/Proxmox.

Packer boots the IOSvL2 disk under QEMU and configures it over the serial console
(the `expect` script): `vagrant/vagrant` privilege-15 user, SSH v2, `GigabitEthernet0/0`
as a DHCP management port in the `Mgmt-intf` VRF, and an EEM applet that regenerates the
SSH keys after a restart.

> **Acknowledgement** — the approach and the original Vagrant/libvirt build come from
> **[@mweisel](https://github.com/mweisel)**. This repo builds on that idea and adds a
> no-Vagrant qcow2 variant for Proxmox.

## Layout

| file | purpose |
|------|---------|
| `cisco-iosvl2.pkr.hcl` | build a **Vagrant box** (libvirt) — the original flow |
| `cisco-iosvl2-no-vagrant.pkr.hcl` | build a bare **qcow2** (no Vagrant post-processing) |
| `cisco_iosvl2_config.exp` | serial-console provisioning, run during both builds |
| `Vagrantfile`, `src/` | example Vagrant topology + box metadata |

Cisco ships IOSvL2 as a `.tgz` holding a single `virtioa.qcow2` — extract it first:
`tar xf viosl2-*.tgz`.

## Build a bare qcow2 (Proxmox/KVM)

```bash
packer init cisco-iosvl2-no-vagrant.pkr.hcl
packer build \
  -var image_path="/path/to/extracted" -var image_name=virtioa.qcow2 \
  cisco-iosvl2-no-vagrant.pkr.hcl
# result: tmp_out/cisco-iosvl2   (a configured qcow2)
```

> Both `.pkr.hcl` files declare the same variables, so always build a **specific file**
> (as above) — don't run `packer build .` on the directory.

## Build a Vagrant box (libvirt)

```bash
PACKER_LOG=1 packer build -var 'version=2025' \
  -var 'image_name=virtioa.qcow2' cisco-iosvl2.pkr.hcl
# result: builds/cisco-iosvl2-<version>.box
```

## Running the qcow2 on Proxmox / KVM

IOSvL2 is picky about virtual hardware — set all three or it won't come up:

- **Disk bus: VirtIO Block or IDE** — *not* virtio-SCSI. On virtio-SCSI IOS can't reach
  `flash0:`, so it boots a blank config and `wr` fails with `flash:/nvram`.
- **NIC model: Intel E1000** — IOSvL2 has no virtio-net driver (virtio NICs are invisible).
- **Console: serial** — `qm set <vmid> -serial0 socket -vga serial0`; the VGA/noVNC
  console goes dark right after the GRUB "Booting IOSv…" line.

Interfaces map one-per-NIC: the first NIC is **Gi0/0** (routed management port, in the
`Mgmt-intf` VRF); each additional NIC becomes **Gi0/1, Gi0/2, …** as L2 switchports.
Login: `vagrant` / `vagrant`.
