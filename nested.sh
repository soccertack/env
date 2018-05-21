#!/bin/bash

HOME=${1:-$HOME}

ARCH=`uname -m`

SRC_BZ=/proj/kvmarm-PG0/jintack/nested/v4.15.img.bz2
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

mkdir -p /mnt_l2
if [[ "$ARCH" == "aarch64" ]]; then
	sudo mount -o loop $IMG_DIR/$TARGET_IMG /mnt
	sudo mount -o loop /mnt/root/vm/l2.img /mnt_l2
elif [[ "$ARCH" == "x86_64" ]]; then
	sudo guestmount -a $IMG_DIR/$TARGET_IMG -m /dev/sda1 /mnt
	sudo guestmount -a /mnt/vm/guest0.img -m /dev/sda1 /mnt_l2
fi

cat $HOME/.ssh/id_rsa.pub | sudo tee -a /mnt/root/.ssh/authorized_keys
cat $HOME/.ssh/id_rsa.pub | sudo tee -a /mnt_l2/root/.ssh/authorized_keys

if [[ "$ARCH" == "aarch64" ]]; then
	sudo umount /mnt_l2
	sudo umount /mnt
elif [[ "$ARCH" == "x86_64" ]]; then
	sudo guestunmount /mnt_l2
	sudo guestunmount /mnt
fi

pushd $SCRIPT_DIR
HOME_LIST="run.sh trap_count.sh pin_vcpus_all.sh"
cp $HOME_LIST $HOME

BIN_LIST="ts tc micro-cycles.py kvm_trace.sh consume_mem.sh copy-ssh-key.sh copy-ssh-key-arm.sh"
BIN=/usr/local/bin
cp $BIN_LIST $BIN
popd
