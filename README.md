# Kubernetes Vagrant

Deploy a Kubernetes cluster using Vagrant.

# Table of Contents

- [Kubernetes Vagrant](#kubernetes-vagrant)
- [Table of Contents](#table-of-contents)
- [Overview](#overview)
- [Requirements](#requirements)
- [Before Start](#before-start)
- [Example Usage](#example-usage)
- [FAQ](#faq)

# Overview

- *Image:* bento/ubuntu-22.04 
- *Docker Version:* latest
- *Kubelet Version:* 1.25
- *Kubectl Version:* 1.25
- *Kubeadm Version:* 1.25
- *CNI:* Flannel | Calico | Cilium (w/ & w/o kubeproxy) | None (latest version)
- *Kube-Proxy* mode: iptables | ipvs (see kube-configuration for ipvs algorithm)
# Requirements
- Install Vagrant: https://www.vagrantup.com/docs/installation
- Install VirtualBox: https://www.virtualbox.org/wiki/Downloads

If you're using windows, I suggest installing the above using Chocolatey: https://chocolatey.org/
# Before Start
```bash
# Install the plugin for Vagrant to ability to use environment files.
$ vagrant plugin install vagrant-env

# Clone the project and go into it.
$ git clone https://github.com/amraninoam/kubernetes-vagrant.git && cd kubernetes-vagrant

# Customize your own environment file.
$ cp .env.example .env
```

# Example Usage

```bash
# Up one master and two worker node.
# This takes approximately ~30 minutes if you using first time.
$ vagrant up m w1 w2

# Connect to master node over SSH.
$ vagrant ssh m

# Connect to master node over SSH and run the roundrobin test.
$ vagrant ssh m -c /vagrant/test-roundrobin.sh

# List nodes.
$ kubectl get nodes
```

# FAQ

**Why Bento?**
- Because HashiCorp (the makers of Vagrant) recommends the Bento Ubuntu.

**Why are the versions fixed?**
- Because major changes over the packages may broke the setup.

**I got error like `Call to WHvSetupPartition failed`, What should I do?**
- Disable Hyper-V on your machine with below steps:
- RUN > CMD > `bcdedit /set hypervisorlaunchtype off`, then reboot your machine.

**How can I re-activete Hyper-V?**
- RUN > CMD > `bcdedit /set hypervisorlaunchtype auto`, then reboot your machine.