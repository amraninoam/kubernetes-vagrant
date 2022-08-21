#!/bin/bash

# Update apt registry.
apt-get update
apt-get upgrade -y

# Pass grub.
# apt-mark hold grub-pc grub-pc-bin grub2-common grub-common

# Upgrade packages and kernel.
# apt-get dist-upgrade -y