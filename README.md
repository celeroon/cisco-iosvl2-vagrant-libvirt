
```
PACKER_LOG=1 packer build -var 'version=2025' -var "image_name=cisco-iosvl2.qcow2" cisco-iosvl2.pkr.hcl
```

```
sudo mv ./builds/cisco-iosvl2-*.box /var/lib/libvirt/images
```

```
sudo cp ./src/cisco-iosvl2.json /var/lib/libvirt/images
```

```
vm_version="2025"
sudo sed -i "s/\"version\": \"VER\"/\"version\": \"$vm_version\"/; s#\"url\": \"file:///var/lib/libvirt/images/cisco-iosvl2-VER.box\"#\"url\": \"file:///var/lib/libvirt/images/cisco-iosvl2-$vm_version.box\"#" /var/lib/libvirt/images/cisco-iosvl2.json
```

```
vagrant box add --box-version 2025 /var/lib/libvirt/images/cisco-iosvl2.json
```
