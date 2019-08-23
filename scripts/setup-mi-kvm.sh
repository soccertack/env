#!/bin/bash

./setup-nfs-server.sh

mount -o loop,offset=1048576 /vm/guest0.img /mnt_l1
cp /mnt_l1/vm/guest0.img /vm_nfs/
