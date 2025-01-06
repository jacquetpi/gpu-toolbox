#!/bin/bash
# https://catalog.ngc.nvidia.com/orgs/nvidia/containers/hpc-benchmarks

g5k-setup-docker -t
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo-g5k apt-get update
sudo apt-get install -y nvidia-container-toolkit
sudo-g5k nvidia-ctk runtime configure --runtime=docker
sudo-g5k systemctl restart docker
sudo-g5k docker pull nvcr.io/nvidia/hpc-benchmarks:24.09
sudo-g5k docker run --gpus all --ipc=host --net=host --ulimit memlock=-1 --ulimit stack=67108864 --rm -it nvcr.io/nvidia/hpc-benchmarks:24.09


# /hpl-linux-x86_64/sample-dat/HPL-1GPU.dat
