#!/bin/bash

SRC_BZ=/proj/kvmarm-PG0/jintack/nested/v4.15.img.bz2
BZ=`echo ${SRC_BZ##*/}`
IMG=`echo ${BZ%.*}`
TARGET_IMG=linaro-trusty.img
IMG_DIR=/vmdata

cp $SRC_BZ $IMG_DIR
pushd $IMG_DIR
pbzip2 -d $BZ
mv $IMG $TARGET_IMG
popd

sudo mount -o loop $IMG_DIR/$TARGET_IMG /mnt
cat $HOME/.ssh/id_rsa.pub | sudo tee -a /mnt/root/.ssh/authorized_keys
mkdir -p /mnt_l2
sudo mount -o loop /mnt/root/vm/l2.img /mnt_l2
cat $HOME/.ssh/id_rsa.pub | sudo tee -a /mnt_l2/root/.ssh/authorized_keys
sudo umount /mnt_l2
sudo umount /mnt

cp nesting/run.sh $HOME
cp nesting/trap_count.sh $HOME
cp nesting/consume_mem.sh $HOME
cp nesting/kvm_trace.sh $HOME
cp nesting/copy-ssh-key.sh $HOME
cp nesting/pin_vcpus_all.sh $HOME
cp nesting/micro-cycles.py $HOME
