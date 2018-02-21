#!/bin/bash

source ~/.cloudlab_ip.sh
echo $IP

OUT=.
md5sum $OUT/arch/arm64/boot/Image
scp $OUT/arch/arm64/boot/Image jintackl@$IP:~
ssh jintackl@$IP "sudo cp ~/Image /srv/vm"
ssh jintackl@$IP "sync"
