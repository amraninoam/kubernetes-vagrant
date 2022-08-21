#!/bin/bash

kubectl run -it --rm --restart=Never --image=busybox busybox -- /bin/sh -c 'for i in `seq 1 10`; do wget -qO - web; echo ; done'