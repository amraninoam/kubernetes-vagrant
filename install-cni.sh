#!/bin/bash
set -e

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
    # Wait for CRD to be available...
    kubectl wait --for condition=established --timeout=60s crd installations.operator.tigera.io -n tigera-operator
    # update pod cidr
    sed -r "s|^(\s*)(cidr)(.*)|\1cidr: $POD_NETWORK_CIDR|gm" /vagrant/cni/calico.yaml > /vagrant/cni/calico.yaml.used
    kubectl apply -f /vagrant/cni/calico.yaml.used
    rm /vagrant/cni/calico.yaml.used
elif [[ "$KUBE_CNI" == "cilium" ]]
then
    # Apply Cilium.
    export CILIUM_VERSION=1.12.1
    echo Applying Cilium version $CILIUM_VERSION...    
    
    helm repo add cilium https://helm.cilium.io/
    helm repo update

    # Install Cilium cli
    CILIUM_CLI_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/cilium-cli/master/stable.txt)
    CLI_ARCH=amd64
    if [ "$(uname -m)" = "aarch64" ]; then CLI_ARCH=arm64; fi
    curl -L --fail --remote-name-all https://github.com/cilium/cilium-cli/releases/download/${CILIUM_CLI_VERSION}/cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}
    sha256sum --check cilium-linux-${CLI_ARCH}.tar.gz.sha256sum
    sudo tar xzvfC cilium-linux-${CLI_ARCH}.tar.gz /usr/local/bin
    rm cilium-linux-${CLI_ARCH}.tar.gz{,.sha256sum}

    # Install Huddle client
    export HUBBLE_VERSION=$(curl -s https://raw.githubusercontent.com/cilium/hubble/master/stable.txt)
    HUBBLE_ARCH=amd64
    if [ "$(uname -m)" = "aarch64" ]; then HUBBLE_ARCH=arm64; fi
    curl -L --fail --remote-name-all https://github.com/cilium/hubble/releases/download/$HUBBLE_VERSION/hubble-linux-${HUBBLE_ARCH}.tar.gz{,.sha256sum}
    sha256sum --check hubble-linux-${HUBBLE_ARCH}.tar.gz.sha256sum
    sudo tar xzvfC hubble-linux-${HUBBLE_ARCH}.tar.gz /usr/local/bin
    rm hubble-linux-${HUBBLE_ARCH}.tar.gz{,.sha256sum}

    cilium install
    # cilium status --wait
    # cilium hubble enable --ui
fi
