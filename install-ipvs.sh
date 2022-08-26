#!/bin/bash
set -e

apt install ipset ipvsadm -y
modprobe ip_vs
modprobe ip_vs_lc
modprobe ip_vs_rr
modprobe ip_vs_wrr
modprobe ip_vs_sh
modprobe nf_conntrack
