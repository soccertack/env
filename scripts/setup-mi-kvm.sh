#!/bin/bash

./setup-nfs-server.sh

pushd /srv/vm
./remove-nested-py
popd

mount -o loop,offset=1048576 /vm/guest0.img /mnt_l1
cp /mnt_l1/vm/guest0.img /vm_nfs/
umount /mnt_l1
