#!/bin/bash

KERNEL_VER=`include/config/kernel.release`
TARGET_IP="128.105.144.25"

time rsync -av /lib/modules/$KERNEL_VER root@$TARGET_IP:/lib/modules/.
time scp /boot/*$KERNEL_VER* root@$TARGET_IP:/boot/.
ssh root@$TARGET_IP 'update-grub'
