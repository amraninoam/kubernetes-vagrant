#!/bin/bash
set -e

echo Applying CRI... got "$KUBE_CRI"
if [ "$KUBE_CRI" == "docker" ]
then
  /vagrant/install-docker.sh
elif [ "$KUBE_CRI" == "containerd" ]
then
  /vagrant/install-containerd.sh
fi