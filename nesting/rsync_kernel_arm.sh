#!/bin/bash

source ~/.cloudlab_ip.sh
echo "----- rsync start ----"
echo $IP

KERNEL_VER="4.15.0+"
INSTALL_MOD_PATH="my_modules"

time rsync -av $INSTALL_MOD_PATH/lib/modules/$KERNEL_VER jintackl@$IP:~
ssh jintackl@$IP "rsync -av $KERNEL_VER/ root@10.10.1.100:/lib/modules/"
echo "----- rsync done ----"
