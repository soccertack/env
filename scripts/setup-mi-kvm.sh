#!/bin/bash

./setup-nfs-client.sh

pushd /srv/vm
./remove-nested.py
popd

# Add client key to the image to be copied first
./mount-and-copy-ssh-key.sh

mount -o loop,offset=1048576 /vm/guest0.img /mnt_l1
echo "copying guest image..."
cp /mnt_l1/vm/guest0.img /vm_nfs/
umount /mnt_l1