#!/bin/bash
echo Applying CNI... got "$KUBE_CNI"
if [ "$KUBE_CNI" == "flannel" ]
then
    # Apply flannel.
    # kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/master/Documentation/kube-flannel.yaml
    # since using oracle virtualbox, had to modify the --iface=eth1 interface. 
    echo Applying flannel...
    # update pod cidr
    sed -r "s|^(\s*)(\"Network\")(.*)|\1\"Network\": \"$POD_NETWORK_CIDR\",|gm" /vagrant/cni/flannel.yaml > /vagrant/cni/flannel.yaml.used
    kubectl apply -f /vagrant/cni/flannel.yaml.used
    rm /vagrant/cni/flannel.yaml.used
elif [ "$KUBE_CNI" == "calico" ]
then
    # Apply Calico.
    echo Applying Calico...
    kubectl create -f https://raw.githubusercontent.com/projectcalico/calico/v3.24.0/manifests/tigera-operator.yaml
    # update pod cidr
    sed -r "s|^(\s*)(cidr)(.*)|\1cidr: $POD_NETWORK_CIDR|gm" /vagrant/cni/calico.yaml > /vagrant/cni/calico.yaml.used
    kubectl apply -f /vagrant/cni/calico.yaml.used
    rm /vagrant/cni/calico.yaml.used
fi