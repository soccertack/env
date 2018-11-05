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

mkdir -p /mnt_l1
if [[ "$ARCH" == "aarch64" ]]; then
	sudo mount -o loop $IMG_DIR/$TARGET_IMG /mnt_l1
elif [[ "$ARCH" == "x86_64" ]]; then
	mount -o loop,offset=1048576 $IMG_DIR/$TARGET_IMG /mnt_l1
fi

cp dest_interfaces /mnt_l1/etc/network/interfaces

sudo umount /mnt_l1
