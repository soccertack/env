#!/bin/bash

if [[ "`whoami`" != "root" ]]; then
	echo "Please run as root"
	exit 1
fi

SDC=`sudo fdisk -l 2>/dev/null | grep "480103981056 bytes" | awk '{print $2}' | cut -d: -f1 | cut -d/ -f3`

if [[ $SDC != "sdc" ]]; then
	echo "Check if you have an SSD disk at /dev/sdc"
	exit
fi

if [[ ! -e /dev/sdc1 ]]; then
	parted -s -a optimal /dev/sdc -- mklabel msdos mkpart primary ext4 1 -1
fi

mount | grep /dev/sdc1 2>&1 > /dev/null
if [[ $? != 0 ]]; then
	mkfs.ext4 /dev/sdc1
	mkdir -p /sdc
	echo "Before change /sdc owner"
	ls -al /sdc
	mount /dev/sdc1 /sdc
	#never tested
	echo "/dev/sdc1 /sdc ext4 defaults 0 0" >> /etc/fstab
	chown jintackl:kvmarm-PG0 /sdc
	echo "After change /sdc owner"
	ls -al /sdc
fi
