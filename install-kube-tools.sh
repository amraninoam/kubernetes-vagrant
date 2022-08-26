#!/bin/bash
set -e

# Install packages to allow apt to use a repository over HTTPS
apt-get install -y apt-transport-https curl

# Add Kubernetes apt repository.

## Download the Google Cloud public signing key
curl -fsSLo /usr/share/keyrings/kubernetes-archive-keyring.gpg https://packages.cloud.google.com/apt/doc/apt-key.gpg

## Add the Kubernetes apt repository
echo "deb [signed-by=/usr/share/keyrings/kubernetes-archive-keyring.gpg] https://apt.kubernetes.io/ kubernetes-xenial main" | sudo tee /etc/apt/sources.list.d/kubernetes.list

## Update apt package index with the new repository
apt-get update

# Install kubelet, kubeadm and kubectl.
apt-get install -y kubelet=$KUBERNETES_VERSION* kubeadm=$KUBERNETES_VERSION* kubectl=$KUBERNETES_VERSION*
sudo apt-mark hold kubelet kubeadm kubectl
# Turn off swap for kubeadm.
swapoff -a
sed -i '/swap/d' /etc/fstab

apt-get install bash-completion
echo 'source <(kubectl completion bash)' >>/home/vagrant/.bashrc
echo 'alias k=kubectl' >>/home/vagrant/.bashrc
echo 'complete -o default -F __start_kubectl k' >>/home/vagrant/.bashrc
source /home/vagrant/.bashrc

# install helm
curl https://baltocdn.com/helm/signing.asc | gpg --dearmor | sudo tee /usr/share/keyrings/helm.gpg > /dev/null
sudo apt-get install apt-transport-https --yes
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/helm.gpg] https://baltocdn.com/helm/stable/debian/ all main" | sudo tee /etc/apt/sources.list.d/helm-stable-debian.list
sudo apt-get update
sudo apt-get install helm