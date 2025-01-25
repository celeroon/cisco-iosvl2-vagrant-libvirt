
ps aux | grep cisco-iosvl2

pkill -f "/usr/bin/qemu-system-x86_64.*-name cisco-iosvl2"


vagrant box add --box-version 2020 /var/lib/libvirt/images/cisco-iosvl2.json


{
  "name": "cisco-iosvl2",
  "description": "This box contains the Cisco IOSv L2 Switch.",
  "versions": [
    {
      "version": "2020",
      "providers": [
        {
          "name": "libvirt",
          "url": "file:///var/lib/libvirt/images/cisco-iosvl2-2020.box"
        }
      ]
    }
  ]
}
