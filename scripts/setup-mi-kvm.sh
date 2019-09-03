#!/bin/bash

./setup-nfs-client.sh

# We are going to support L1+L2 migration, so we don't
# need to remove nested=1 option
#pushd /srv/vm
#./remove-nested.py
#popd

# Add client key to the image to be copied first
./mount-and-copy-ssh-key.sh

read -p "Virtualization level for migration?[1 or 2]: " level
if [ $level == "1" ]; then
	IMG="/vm_nfs/guest_l1.img"
	if [ ! -f "$IMG" ]; then
		echo "copying guest image..."
		cp /vm/guest0.img $IMG
	fi
elif [ $level == "2" ]; then
	IMG="/vm_nfs/guest_l2.img"
	if [ ! -f "$IMG" ]; then
		mount -o loop,offset=1048576 /vm/guest0.img /mnt_l1
		echo "copying guest image..."
		cp /mnt_l1/vm/guest0.img $IMG
		umount /mnt_l1
	fi
else
	echo "Only level 1 or 2 is supported"
	exit
fi

rm /vm_nfs/guest0.img
ln -s $IMG /vm_nfs/guest0.img
