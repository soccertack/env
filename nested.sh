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

	# Until g5 issue accessing /proj is resolved, let's do it manually
	exit
else
	TARGET_IMG=linaro-trusty.img
	IMG_DIR=/vmdata
fi

if [ -f $IMG_DIR/$BZ ]; then
	echo "Skip copying $BZ. The file already exists"
else
	echo "Copying ${BZ}..."
	cp $SRC_BZ $IMG_DIR
	echo "Done"
fi
pushd $IMG_DIR
pbzip2 -kd $BZ
mv $IMG $TARGET_IMG
popd

echo "Trying to sync"
time sync
echo "Sync done"

mkdir -p /mnt_l1
mkdir -p /mnt_l2
mkdir -p /mnt_l3
if [[ "$ARCH" == "aarch64" ]]; then
	sudo mount -o loop $IMG_DIR/$TARGET_IMG /mnt_l1
	sudo mount -o loop /mnt_l1/root/vm/l2.img /mnt_l2
elif [[ "$ARCH" == "x86_64" ]]; then
	echo "Skip copying ssh key. Do it manually"
#	apt-get install -y libguestfs-tools
#	echo "Trying to mount L1 image"
#	time sudo guestmount -a $IMG_DIR/$TARGET_IMG -m /dev/sda1 /mnt_l1
#	echo "Done."
#	echo "Trying to mount L2 image"
#	time sudo guestmount -a /mnt_l1/vm/guest0.img -m /dev/sda1 /mnt_l2
#	echo "Done."
#	if [[ -f /mnt_l2/vm/guest.img ]]; then
#		echo "Trying to mount L3 image"
#		sudo guestmount -a /mnt_l2/vm/guest0.img -m /dev/sda1 /mnt_l3
#		echo "Done."
#	fi
fi

if [[ "$ARCH" == "aarch64" ]]; then
	cat $HOME/.ssh/id_rsa.pub | sudo tee -a /mnt_l1/root/.ssh/authorized_keys
	cat $HOME/.ssh/id_rsa.pub | sudo tee -a /mnt_l2/root/.ssh/authorized_keys
	if [[ -f /mnt_l2/vm/guest.img ]]; then
		cat $HOME/.ssh/id_rsa.pub | sudo tee -a /mnt_l3/root/.ssh/authorized_keys
	fi
fi

if [[ "$ARCH" == "aarch64" ]]; then
	sudo umount /mnt_l3
	sudo umount /mnt_l2
	sudo umount /mnt_l1
elif [[ "$ARCH" == "x86_64" ]]; then
	echo ""
#	echo "Trying to unmount all"
#	if [[ -f /mnt_l2/vm/guest.img ]]; then
#		sudo guestunmount /mnt_l3
#	fi
#	sudo guestunmount /mnt_l2
#	sudo guestunmount /mnt_l1
#	echo "Done."
fi

pushd $SCRIPT_DIR
HOME_LIST="run.sh trap_count.sh pin_vcpus_all.sh"
cp $HOME_LIST $HOME

BIN_LIST="ts tc micro-cycles.py kvm_trace.sh consume_mem.sh copy-ssh-key.sh copy-ssh-key-arm.sh"
BIN=/usr/local/bin
cp $BIN_LIST $BIN
popd
