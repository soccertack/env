#!/bin/bash

VM=/vmdata
HOST_KEYS=~/.ssh/authorized_keys
GUEST_KEYS=/root/.ssh/authorized_keys

echo $1 >> $HOST_KEYS

#Check if qemu is running
pgrep qemu
err=$?
if [[ $err == 0 ]]; then
	echo "QEMU is running. Please terminate VM(s) to update ssh keys"
	exit 1
fi

mount -o loop $VM/linaro-trusty.img /mnt
echo $1 >> /mnt/$GUEST_KEYS

mount -o loop /mnt/root/vm/l2.img /mnt_l2
echo $1 >> /mnt_l2/$GUEST_KEYS

umount /mnt_l2
umount /mnt
