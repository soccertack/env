#!/bin/bash

source ~/.cloudlab_ip.sh

VM=/vmdata
KVM_L2=.
md5sum $KVM_L2/arch/arm64/boot/Image
echo $IP
scp $KVM_L2/arch/arm64/boot/Image jintackl@$IP:~/L2_Image
ssh jintackl@$IP "sudo mount -o loop $VM/linaro-trusty.img /mnt"
ssh jintackl@$IP "sudo cp ~/L2_Image  /mnt/root/vm/Image"
ssh jintackl@$IP "sudo umount /mnt"
ssh jintackl@$IP "sync"
