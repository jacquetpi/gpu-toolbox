#!/bin/bash
# Setup Hook (Not needed)

sudo-g5k wget 'https://raw.githubusercontent.com/PassthroughPOST/VFIO-Tools/master/libvirt_hooks/qemu' -O /etc/libvirt/hooks/qemu
sudo-g5k chmod +x /etc/libvirt/hooks/qemu
sudo-g5k service libvirtd restart
cat tools/kvm.conf | sed "s/XXX/$pcie/g" | sudo-g5k tee /etc/libvirt/hooks/kvm.conf

sudo-g5k mkdir -p /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin /etc/libvirt/hooks/qemu.d/$vmname/release/end
sudo-g5k cp tools/bind_vfio.sh /etc/libvirt/hooks/qemu.d/$vmname/prepare/begin
sudo-g5k cp tools/unbind_vfio.sh /etc/libvirt/hooks/qemu.d/$vmname/release/end