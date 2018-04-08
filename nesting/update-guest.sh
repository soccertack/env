#!/bin/bash

source ~/.cloudlab_ip.sh
echo $IP

OUT=.

MD5_CMD="ssh jintackl@${IP} md5sum /srv/vm/Image | awk '{print \$1}'"
MD5_SERV="`eval ${MD5_CMD}`"
MD5_LOCAL="`md5sum $OUT/arch/arm64/boot/Image | awk '{print $1}'`"

# Update Image file only if it is out-of date
if [ "$MD5_SERV" == "$MD5_LOCAL" ]; then
	echo "The server Image is up-to-date."
	echo $MD5_SERV
	exit
fi

scp $OUT/arch/arm64/boot/Image jintackl@$IP:/tmp
ssh jintackl@$IP "sudo cp /tmp/Image /srv/vm"
ssh jintackl@$IP "sync"
