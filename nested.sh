#!/bin/bash

HOME=${1:-$HOME}

SRC_BZ=/proj/kvmarm-PG0/jintack/nested/v4.15.img.bz2
BZ=`echo ${SRC_BZ##*/}`
IMG=`echo ${BZ%.*}`
TARGET_IMG=linaro-trusty.img
IMG_DIR=/vmdata
SCRIPT_DIR=nesting

cp $SRC_BZ $IMG_DIR
pushd $IMG_DIR
pbzip2 -kd $BZ
mv $IMG $TARGET_IMG
popd

sudo mount -o loop $IMG_DIR/$TARGET_IMG /mnt
cat $HOME/.ssh/id_rsa.pub | sudo tee -a /mnt/root/.ssh/authorized_keys
mkdir -p /mnt_l2
sudo mount -o loop /mnt/root/vm/l2.img /mnt_l2
cat $HOME/.ssh/id_rsa.pub | sudo tee -a /mnt_l2/root/.ssh/authorized_keys
sudo umount /mnt_l2
sudo umount /mnt

pushd $SCRIPT_DIR
HOME_LIST="run.sh trap_count.sh consume_mem.sh copy-ssh-key.sh copy-ssh-key-arm.sh pin_vcpus_all.sh"
cp $HOME_LIST $HOME

BIN_LIST="ts tc micro-cycles.py kvm_trace.sh"
BIN=/usr/local/bin
cp $BIN_LIST $BIN
popd
