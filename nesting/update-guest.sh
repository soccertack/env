#!/bin/bash

source ~/.cloudlab_ip.sh

OUT=.

md5sum $OUT/arch/arm64/boot/Image
echo $IP
scp $OUT/arch/arm64/boot/Image jintackl@$IP:~
ssh jintackl@$IP "sudo cp ~/Image /srv/vm"
ssh jintackl@$IP "sync"
