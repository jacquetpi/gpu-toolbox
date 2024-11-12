#!/bin/bash

source "/etc/libvirt/hooks/kvm.conf"

## Rebind to host
virsh nodedev-reattach $VIRSH_GPU_VIDEO

## Unload VFIO
modprobe -r vfio_pci
modprobe -r vfio_iommu_type1
modprobe -r vfio
