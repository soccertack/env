#!/bin/bash

UIMAGE=arch/arm64/boot/uImage
IMAGE=arch/arm64/boot/Image
OUT=.

if [ "$OUT/$UIMAGE" -ot "$OUT/$IMAGE" ]; then
	echo "Generate uImage..."
	mkimage -A arm -O linux -C none -T kernel -a 0x00080000 -e 0x00080000 -n Linux \
	-d $OUT/arch/arm64/boot/Image $OUT/arch/arm64/boot/uImage
fi

source ~/.cloudlab_ip.sh
echo $IP

md5sum $OUT/arch/arm64/boot/uImage
scp $OUT/arch/arm64/boot/uImage jintackl@$IP:~
ssh jintackl@$IP "sudo cp ~/uImage /boot/uImage-columbia"
ssh jintackl@$IP "sync"
ssh jintackl@$IP "sudo reboot now"
