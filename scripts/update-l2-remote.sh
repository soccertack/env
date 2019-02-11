#!/bin/bash

#Check if qemu is running
pgrep qemu
err=$?
if [[ $err == 0 ]]; then
	echo "QEMU is running. Please terminate VM(s) to update L2 VM kernel"
	exit 1
fi

source ~/.cloudlab_ip.sh

VM=/vmdata
KVM_L2=.
md5sum $KVM_L2/arch/arm64/boot/Image
echo $IP

scp $KVM_L2/arch/arm64/boot/Image jintackl@$IP:/tmp
ssh jintackl@$IP "sudo mount -o loop $VM/linaro-trusty.img /mnt"
ssh jintackl@$IP "sudo cp /tmp  /mnt/root/vm/Image"
ssh jintackl@$IP "sudo umount /mnt"
ssh jintackl@$IP "sync"

