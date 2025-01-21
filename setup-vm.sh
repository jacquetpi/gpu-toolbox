#!/bin/bash

# Variables (retrieve PCIe address of GC and VM parameters)

pcie="pci_0000_$(tools/iommu.sh | grep NVIDIA | head -n 1 | cut -d ' ' -f4 | sed 's/:/_/g' | sed 's/\./_/g')"
pathbase=/home/pjacquet/qcow2
vmcpu=4
vmmem=8192
vmname="vm1"

# Optimize performance

echo always | sudo-g5k tee /sys/kernel/mm/transparent_hugepage/enabled    # Enable hugepages
echo always | sudo-g5k tee /sys/kernel/mm/transparent_hugepage/defrag     # Enable hugepages
echo 3 | sudo-g5k tee /proc/sys/vm/drop_caches                            # Clear caches to maximize available RAM
echo 1 | sudo-g5k tee /proc/sys/vm/compact_memory                         # Rearrange RAM usage to maximise the size of free blocks

# Install requirements

sudo-g5k apt install -y stress-ng sysfsutils nvtop qemu-kvm virtinst libvirt-clients bridge-utils libvirt-daemon-system
echo "mode class/powercap/intel-rapl:0/energy_uj = 0444" | sudo-g5k tee --append /etc/sysfs.conf
sudo-g5k chmod -R a+r /sys/class/powercap/intel-rapl
sudo-g5k addgroup "$(whoami)" libvirt
sudo-g5k addgroup "$(whoami)" kvm
gpu missing gpu when attach to vm
# Setup network

virsh --connect=qemu:///system net-define /usr/share/libvirt/networks/default.xml
virsh --connect=qemu:///system net-autostart default
virsh --connect=qemu:///system net-start default

# Unload NVIDIA kernel modules (by first stopping services of lsof /dev/nvidia*)
sudo-g5k systemctl stop dcgm-exporter.service
#sudo-g5k systemctl stop nvidia-persistenced.service

# Unload NVIDIA kernel modules (to detach GPU from host)
sudo-g5k modprobe -r nvidia_drm 
sudo-g5k modprobe -r nvidia_modeset
sudo-g5k modprobe -r nvidia_uvm 
sudo-g5k modprobe -r nvidia

## Load VFIO (to attach GPU to a VM)
sudo-g5k modprobe vfio
sudo-g5k modprobe vfio_iommu_type1
sudo-g5k modprobe vfio_pci

# Setup MIG (Muli-Instance GPU - Spatial) or vCS (virtual Compute Server - Temporal)
#MIG:
# https://www.nvidia.com/content/dam/en-zz/Solutions/design-visualization/solutions/resources/documents1/Technical-Brief-Multi-Instance-GPU-NVIDIA-Virtual-Compute-Server.pdf
#vCS: (it is not free)
# https://www.nvidia.com/content/dam/en-zz/Solutions/design-visualization/solutions/resources/documents1/Technical-Brief-Multi-Instance-GPU-NVIDIA-Virtual-Compute-Server.pdf

# Install VM
virt-install --connect qemu:///system --import --name $vmname --vcpu $vmcpu --memory $vmmem --disk $pathbase/$vmname.qcow2,format=qcow2,bus=virtio --import --os-variant ubuntu20.04 --network network=default --virt-type kvm --noautoconsole --check path_in_use=off --host-device $pcie
# Post action : wait to retrieve vm ip
while sleep 5;
do
  vm_ip=$( virsh --connect=qemu:///system domifaddr "$vmname" | tail -n 2 | head -n 1 | awk '{ print $4 }' | sed 's/[/].*//' );
  if [ -n "$vm_ip" ]; then #VAR is set to a non-empty string
    break
  fi
done
ssh vm@"${vm_ip}" -o StrictHostKeyChecking=no "sudo apt update && sudo apt install -y nvidia-driver-550-server nvidia-utils-550-server && sudo reboot"
# May not be fully initialized : test if ssh works (is ping enough?)
count=0
while true;
do
  ssh_test=$( ssh vm@"${vm_ip}" -o StrictHostKeyChecking=no 'echo success' )
  if [[ $ssh_test == *"success"* ]]; then
    echo "Setup : vm $vmname ready with ip $vm_ip"
    break
  fi
  count=$(( count + 1 ))
  echo "Setup : unable to ssh test vm $vmname with ip $vm_ip (trial $count)"
  sleep 15
done