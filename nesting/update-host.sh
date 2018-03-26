#!/bin/bash

UIMAGE=arch/arm64/boot/uImage
IMAGE=arch/arm64/boot/Image
OUT=.

# Create uImage file only if it is out-of date
if [ "$OUT/$UIMAGE" -ot "$OUT/$IMAGE" ]; then
	echo "Generate uImage..."
	mkimage -A arm -O linux -C none -T kernel -a 0x00080000 -e 0x00080000 -n Linux \
	-d $OUT/arch/arm64/boot/Image $OUT/arch/arm64/boot/uImage
fi

source ~/.cloudlab_ip.sh

MD5_LOCAL="`md5sum ${OUT}/arch/arm64/boot/uImage | awk '{print $1}'`"

MD5_CMD="ssh jintackl@${IP} md5sum /boot/uImage-columbia | awk '{print \$1}'"
MD5_SERV="`eval ${MD5_CMD}`"

# Update uImage file only if it is out-of date
if [ "$MD5_SERV" == "$MD5_LOCAL" ]; then
	echo "The server uImage is up-to-date."
	echo $MD5_SERV
	exit
fi

scp $OUT/arch/arm64/boot/uImage jintackl@$IP:~
ssh jintackl@$IP "sudo cp ~/uImage /boot/uImage-columbia"
ssh jintackl@$IP "sync"
ssh jintackl@$IP "sudo reboot now"
