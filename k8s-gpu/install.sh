#!/bin/bash
# Install Docker
echo ">>Install Docker"
g5k-setup-docker -t
# Install k8s
echo ">>Install kubectl"
sudo-g5k apt-get update
sudo-g5k apt-get install -y apt-transport-https ca-certificates curl gnupg
sudo-g5k mkdir -p -m 755 /etc/apt/keyrings
curl -fsSL https://pkgs.k8s.io/core:/stable:/v1.32/deb/Release.key | sudo-g5k gpg --dearmor -o /etc/apt/keyrings/kubernetes-apt-keyring.gpg
curl -fsSL https://nvidia.github.io/libnvidia-container/gpgkey | sudo-g5k gpg --dearmor -o /usr/share/keyrings/nvidia-container-toolkit-keyring.gpg \
  && curl -s -L https://nvidia.github.io/libnvidia-container/stable/deb/nvidia-container-toolkit.list | \
    sed 's#deb https://#deb [signed-by=/usr/share/keyrings/nvidia-container-toolkit-keyring.gpg] https://#g' | \
    sudo-g5k tee /etc/apt/sources.list.d/nvidia-container-toolkit.list
sudo-g5k chmod 644 /etc/apt/keyrings/kubernetes-apt-keyring.gpg # allow unprivileged APT programs to read this keyring
# This overwrites any existing configuration in /etc/apt/sources.list.d/kubernetes.list
echo 'deb [signed-by=/etc/apt/keyrings/kubernetes-apt-keyring.gpg] https://pkgs.k8s.io/core:/stable:/v1.32/deb/ /' | sudo-g5k tee /etc/apt/sources.list.d/kubernetes.list
sudo-g5k chmod 644 /etc/apt/sources.list.d/kubernetes.list   # helps tools such as command-not-found to work correctly
sudo-g5k apt-get update
sudo-g5k apt-get install -y nvidia-container-toolkit kubectl 
kubectl version --client
# Install minikube
echo ">>Install minikube"
echo "net.core.bpf_jit_harden=0" | sudo-g5k tee -a /etc/sysctl.conf
sudo-g5k sysctl -p
curl -Lo minikube https://storage.googleapis.com/minikube/releases/latest/minikube-linux-amd64 && chmod +x minikube
sudo-g5k mkdir -p /usr/local/bin/
sudo-g5k install minikube /usr/local/bin/
minikube start --driver docker --container-runtime docker --gpus all
# Apply oversubscription policy
echo ">>Apply oversubscription policy"
kubectl create -n default -f time-slicing-config-all.yaml
kubectl patch clusterpolicies.nvidia.com/cluster-policy \
    -n gpu-operator --type merge \
    -p '{"spec": {"devicePlugin": {"config": {"name": "time-slicing-config-all", "default": "any"}}}}'
echo ">>Done!"w

# Install GPU-Operator : https://docs.nvidia.com/datacenter/cloud-native/gpu-operator/latest/getting-started.html#prerequisites
#echo "Install Nvidia GPU operator"

