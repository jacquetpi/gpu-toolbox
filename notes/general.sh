#!/bin/bash

# Remote access
virsh -c "qemu+ssh://pjacquet@chifflot-8.lille.g5k/system" nodeinfo

# Hot unplug
virsh --connect=qemu:///system detach-device vm1 gpu.xml
virsh --connect=qemu:///system nodedev-reattach $VIRSH_GPU_VIDEO # To reattach but does not seem to be necessary

# Debug
sudo-g5k journalctl -u libvirtd
sudo-g5k dmesg | grep IOMMU
sudo-g5k dmesg | grep VT-d      # Intel
sudo-g5k dmesg | grep AMD-Vi    # AMD
lspci -nn | grep -E "NVIDIA" # grep last identifiers in [ XX ]
