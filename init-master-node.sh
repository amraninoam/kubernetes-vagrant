#!/bin/bash
set -e

# Replace advertising address with $NODE_IP
cp /vagrant/kubernetes/kube-configuration.yaml /vagrant/kubernetes/kube-configuration.yaml.used
sed -ri "s|^(\s*)(advertiseAddress)(.*)|\1advertiseAddress: $NODE_IP|gm" /vagrant/kubernetes/kube-configuration.yaml.used
sed -ri "s|^(\s*)(podSubnet)(.*)|\1podSubnet: $POD_NETWORK_CIDR|gm" /vagrant/kubernetes/kube-configuration.yaml.used
sed -ri "s|^(\s*)(mode)(.*)|\1mode: $KUBE_PROXY_MODE|gm" /vagrant/kubernetes/kube-configuration.yaml.used
sed -ri "s|^(\s*)(bindPort)(.*)|\1bindPort: $NODE_API_PORT|gm" /vagrant/kubernetes/kube-configuration.yaml.used
sed -ri "s|^(\s*)(kubernetesVersion)(.*)|\1kubernetesVersion: v$KUBERNETES_VERSION|gm" /vagrant/kubernetes/kube-configuration.yaml.used

if [ "$KUBE_PROXY_MODE" == "ipvs" ]
then
sed -ri "s|^(# ipvs:)(.*)|\ipvs:|gm" /vagrant/kubernetes/kube-configuration.yaml.used
sed -ri "s|^(#   scheduler:)(.*)|\  scheduler:\2|gm" /vagrant/kubernetes/kube-configuration.yaml.used

fi

if [ "$KUBE_CRI" == "docker" ]
then
  CRI_SOCKET="unix:///var/run/cri-dockerd.sock"
elif [ "$KUBE_CRI" == "containerd" ]
then
  CRI_SOCKET="unix:///run/containerd/containerd.sock"
fi
sed -ri "s|^(\s*)(criSocket)(.*)|\1criSocket: \"$CRI_SOCKET\"|gm" /vagrant/kubernetes/kube-configuration.yaml.used


echo "Environment='KUBELET_EXTRA_ARGS=--node-ip=$NODE_IP'" | tee -a /etc/systemd/system/kubelet.service.d/10-kubeadm.conf
# Install kubernetes via kubeadm.
kubeadm init --config=/vagrant/kubernetes/kube-configuration.yaml.used
rm /vagrant/kubernetes/kube-configuration.yaml.used

# Hostname -i must return a routable address on second (non-NATed) network interface.
# @see http://kubernetes.io/docs/getting-started-guides/kubeadm/#limitations
sed "s/127.0.0.1.*m/$NODE_IP m/" -i /etc/hosts

# Export k8s cluster token to an external file.
OUTPUT_FILE=/vagrant/join.sh
rm -rf /vagrant/join.sh

kubeadm token create --print-join-command > /vagrant/join.sh
sed -ri "s|^(\s*)(kubeadm join)(.*)|\1kubeadm join --cri-socket=\"$CRI_SOCKET\"\3|gm" /vagrant/join.sh
chmod +x $OUTPUT_FILE
