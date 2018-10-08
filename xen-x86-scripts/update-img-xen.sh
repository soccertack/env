#!/bin/bash

# Update network settings in DomU - only non-nested for now

ARCH=`uname -m`

if [[ "$ARCH" == "x86_64" ]]; then
	TARGET_IMG=guest0.img
	IMG_DIR=/vm
else
	TARGET_IMG=linaro-trusty.img
	IMG_DIR=/vmdata
fi

L3_IMG=0
mkdir -p /mnt_l1
mkdir -p /mnt_l2
mkdir -p /mnt_l3
if [[ "$ARCH" == "aarch64" ]]; then
	sudo mount -o loop $IMG_DIR/$TARGET_IMG /mnt_l1
	sudo mount -o loop /mnt_l1/root/vm/l2.img /mnt_l2
elif [[ "$ARCH" == "x86_64" ]]; then
	mount -o loop,offset=1048576 $IMG_DIR/$TARGET_IMG /mnt_l1
	mount -o loop,offset=1048576 /mnt_l1/vm/guest0.img /mnt_l2
	if [[ -f /mnt_l2/vm/guest0.img ]]; then
		mount -o loop,offset=1048576 /mnt_l2/vm/guest0.img /mnt_l3
		L3_IMG=1
	fi
fi

cp interfaces /mnt_l1/etc/network/interfaces
echo "nameserver 8.8.8.8" >> /mnt_l1/etc/resolv.conf

if [[ $L3_IMG == 1 ]]; then
	sudo umount /mnt_l3
fi
sudo umount /mnt_l2
sudo umount /mnt_l1
