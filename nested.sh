#!/bin/bash

HOME=${1:-$HOME}

ARCH=`uname -m`

SRC_BZ=/proj/kvmarm-PG0/jintack/nested/v4.15.img.bz2
SRC_BZ=${2:-$SRC_BZ}
BZ=`echo ${SRC_BZ##*/}`
IMG=`echo ${BZ%.*}`
SCRIPT_DIR=nesting
if [[ "$ARCH" == "x86_64" ]]; then
	TARGET_IMG=guest0.img
	IMG_DIR=/vm
else
	TARGET_IMG=linaro-trusty.img
	IMG_DIR=/vmdata
fi

cp $SRC_BZ $IMG_DIR
pushd $IMG_DIR
pbzip2 -kd $BZ
mv $IMG $TARGET_IMG
popd

mkdir -p /mnt_l1
mkdir -p /mnt_l2
mkdir -p /mnt_l3
if [[ "$ARCH" == "aarch64" ]]; then
	sudo mount -o loop $IMG_DIR/$TARGET_IMG /mnt_l1
	sudo mount -o loop /mnt_l1/root/vm/l2.img /mnt_l2
elif [[ "$ARCH" == "x86_64" ]]; then
	sudo guestmount -a $IMG_DIR/$TARGET_IMG -m /dev/sda1 /mnt_l1
	sudo guestmount -a /mnt_l1/vm/guest0.img -m /dev/sda1 /mnt_l2
	if [[ -f /mnt_l2/vm/guest.img ]]; then
		sudo guestmount -a /mnt_l2/vm/guest0.img -m /dev/sda1 /mnt_l3
	fi
fi

cat $HOME/.ssh/id_rsa.pub | sudo tee -a /mnt_l1/root/.ssh/authorized_keys
cat $HOME/.ssh/id_rsa.pub | sudo tee -a /mnt_l2/root/.ssh/authorized_keys
if [[ -f /mnt_l2/vm/guest.img ]]; then
	cat $HOME/.ssh/id_rsa.pub | sudo tee -a /mnt_l3/root/.ssh/authorized_keys
fi

if [[ "$ARCH" == "aarch64" ]]; then
	sudo umount /mnt_l3
	sudo umount /mnt_l2
	sudo umount /mnt_l1
elif [[ "$ARCH" == "x86_64" ]]; then
	if [[ -f /mnt_l2/vm/guest.img ]]; then
		sudo guestunmount /mnt_l3
	fi
	sudo guestunmount /mnt_l2
	sudo guestunmount /mnt_l1
fi

pushd $SCRIPT_DIR
HOME_LIST="run.sh trap_count.sh pin_vcpus_all.sh"
cp $HOME_LIST $HOME

BIN_LIST="ts tc micro-cycles.py kvm_trace.sh consume_mem.sh copy-ssh-key.sh copy-ssh-key-arm.sh"
BIN=/usr/local/bin
cp $BIN_LIST $BIN
popd
