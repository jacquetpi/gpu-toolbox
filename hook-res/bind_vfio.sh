#!/bin/bash

source "/etc/libvirt/hooks/kvm.conf"

## Load VFIO
modprobe vfio
modprobe vfio_iommu_type1
modprobe vfio_pci

## Unbind Host
virsh nodedev-detach $VIRSH_GPU_VIDEO
