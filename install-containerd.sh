#!/bin/bash

#Install containerd
export CD_VERSION=1.6.8

wget -q https://github.com/containerd/containerd/releases/download/v${CD_VERSION}/containerd-${CD_VERSION}-linux-amd64.tar.gz
tar Czxvf /usr/local containerd-${CD_VERSION}-linux-amd64.tar.gz
rm containerd-${CD_VERSION}-linux-amd64.tar.gz

wget -q https://raw.githubusercontent.com/containerd/containerd/main/containerd.service
mv containerd.service /usr/lib/systemd/system/

systemctl daemon-reload
systemctl enable --now containerd

#Install RunC
wget -q https://github.com/opencontainers/runc/releases/download/v1.1.1/runc.amd64
install -m 755 runc.amd64 /usr/local/sbin/runc

#Configure containerd for kubernetes
mkdir -p /etc/containerd
[[ ! -f /etc/containerd/config.toml ]] && containerd config default | sudo tee /etc/containerd/config.toml
#https://kubernetes.io/docs/setup/production-environment/container-runtimes/#containerd-systemd
sed -ri "s|^(\s*)(SystemdCgroup)(.*)|\SystemdCgroup = true|gm" /etc/containerd/config.toml

systemctl daemon-reload
systemctl restart containerd
systemctl enable --now containerd