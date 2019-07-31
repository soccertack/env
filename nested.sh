#!/bin/bash

HOME=${1:-$HOME}

ARCH=`uname -m`

BZ_DIR=/proj/kvmarm-PG0/jintack/nested
VER=4.15
VER=${2:-$VER}
BZ=v${VER}.img.bz2
#BZ=`echo ${SRC_BZ##*/}`
IMG=`echo ${BZ%.*}`
SCRIPT_DIR=scripts
NEED_VM_SETUP=0
if [[ "$ARCH" == "x86_64" ]]; then
	TARGET_IMG=guest0.img
	IMG_DIR=/vm
else
	TARGET_IMG=linaro-trusty.img
	IMG_DIR=/vmdata
fi

if [ -f $IMG_DIR/$BZ ]; then
	echo "Skip copying $BZ. The file already exists"
else
#	if [[ "$ARCH" == "x86_64" ]]; then
#		# Until g5 issue accessing /proj is resolved, let's do it manually
#		echo "Please copy guest image manually."
#		exit
#	fi
	echo "Copying ${BZ}..."
	cp ${BZ_DIR}/$BZ $IMG_DIR
	echo "Done"
fi

if [ -f $IMG_DIR/$TARGET_IMG ]; then
	echo "Skip unzip $BZ. The target file already exists"
else
	pushd $IMG_DIR
	pbzip2 -kd $BZ
	mv $IMG $TARGET_IMG
	popd
	NEED_VM_SETUP=1
fi

echo "Trying to sync"
time sync
echo "Sync done"

if [ "$NEED_VM_SETUP" == 0 ]; then
	echo "Does't need VM setup"
	exit
fi

L3_IMG=0
mkdir -p /mnt_l1
mkdir -p /mnt_l2
mkdir -p /mnt_l3
if [[ "$ARCH" == "aarch64" ]]; then
	sudo mount -o loop $IMG_DIR/$TARGET_IMG /mnt_l1
	sudo mount -o loop /mnt_l1/root/vm/l2.img /mnt_l2
elif [[ "$ARCH" == "x86_64" ]]; then
	mount -o loop,offset=1048576 $IMG_DIR/$TARGET_IMG /mnt_l1
	mount -o loop,offset=1048576 /mnt_l1/vm/guest0.img /mnt_l2
	if [[ -f /mnt_l2/vm/guest0.img ]]; then
		mount -o loop,offset=1048576 /mnt_l2/vm/guest0.img /mnt_l3
		L3_IMG=1
	fi
fi

BIN=/usr/local/bin
pushd $SCRIPT_DIR
BIN_LIST="kvm_trace dvh"
cp $BIN_LIST /mnt_l1/$BIN
cp $BIN_LIST /mnt_l2/$BIN
popd

pushd /mnt_l1/root/vm
git pull
popd

pushd /mnt_l2/root/vm
git pull
popd

cat $HOME/.ssh/id_rsa.pub | sudo tee -a /mnt_l1/root/.ssh/authorized_keys
cat $HOME/.ssh/id_rsa.pub | sudo tee -a /mnt_l2/root/.ssh/authorized_keys

cp zshrc /mnt_l1/root/.zshrc
cp alias /mnt_l1/root/.myalias
cp zshrc /mnt_l2/root/.zshrc
cp alias /mnt_l2/root/.myalias
if [[ $L3_IMG == 1 ]]; then
	cat $HOME/.ssh/id_rsa.pub | sudo tee -a /mnt_l3/root/.ssh/authorized_keys
	cp zshrc /mnt_l3/root/.zshrc
	cp alias /mnt_l3/root/.myalias
	sudo umount /mnt_l3
fi

sudo umount /mnt_l2
sudo umount /mnt_l1

pushd $SCRIPT_DIR
HOME_LIST="run.sh trap_count.sh pin_vcpus_all.sh"
cp $HOME_LIST $HOME

BIN_LIST="ts tc micro-cycles.py kvm_trace consume_mem.sh copy-ssh-key.sh copy-ssh-key-arm.sh dvh"
cp $BIN_LIST $BIN
popd

pushd /vm
git pull
popd
cp zshrc /root/.zshrc
cp alias /root/.myalias
