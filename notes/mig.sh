#!/bin/bash

# Check if MIG enabled
nvidia-smi -i <GPU IDs> -q | head -n 80
# Check who use gpu
# (sudo) /proc/*/fd/* -l | grep /dev/nvid
#  Disable process using GPU for reset
sudo-g5k systemctl stop nvidia-persistenced
sudo-g5k systemctl stop dcgm
sudo-g5k systemctl stop dcgm-exporter
# Enable mig on g5k
sudo-g5k nvidia-smi -i 0 -pm 1
sudo-g5k nvidia-smi -i 0 -mig 1
sudo-g5k nvidia-smi -i 0 --gpu-reset
# Re-enable process
sudo-g5k systemctl start nvidia-persistenced
sudo-g5k systemctl start dcgm
sudo-g5k systemctl start dcgm-exporter
# Check GI (GI: gpu instance) capabilities and placements
nvidia-smi mig -lgip
nvidia-smi mig -lgipp
# Create two GIs of type 9
sudo-g5k nvidia-smi mig -cgi 9,9
sudo-g5k nvidia-smi mig -lgi
# Create GI type 19, then 14 then 5
sudo-g5k nvidia-smi mig -cgi 19,14,5
sudo-g5k  nvidia-smi mig -lci
# Check CI (Compute Instance) possibilities for GI id 1 and placements
sudo-g5k nvidia-smi mig -lcip -gi 1
sudo-g5k nvidia-smi mig -lcipp -gi 1
# Create a CI (Compute Instance) and affect it to gi 1
sudo-g5k  nvidia-smi mig -cci 0 -gi 1
# List CI on specific GI
sudo-g5k  nvidia-smi mig -lci -gi 13
# Display config
nvidia-smi -L

# Use it 
# Using data from nvidia-smi -L
docker run --runtime=nvidia -e NVIDIA_VISIBLE_DEVICES="gpu-id:mig-device-id" gpu_burn nvidia-smi -L
docker run --runtime=nvidia -e NVIDIA_VISIBLE_DEVICES="MIG-c7c4f37c-c47e-566f-8685-577096d87634" gpu_burn nvidia-smi -L


# Clear all CI and GI
sudo-g5k nvidia-smi mig -dci && sudo-g5k nvidia-smi mig -dgi