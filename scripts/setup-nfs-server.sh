#!/bin/bash

NFS_DIR=${1:-/sdc}
VM_DIR=/vm

DEFAULT_DIR=/sdc
read -p "nfs source dir[$DEFAULT_DIR]: " dir
NFS_DIR=${dir:-$DEFAULT_DIR}
echo $NFS_VER

if [ "$NFS_DIR" == "$DEFAULT_DIR" ]; then
	read -p "Want to create file system at $DEFAULT_DIR?[y/n]: " yesno
	if [ $yesno == "y" ]; then
		source mkfs-wisc-sdc.sh
	fi
fi

apt-get update
apt-get -y install nfs-kernel-server
echo "$NFS_DIR *(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
echo "$VM_DIR *(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
exportfs -a
service nfs-kernel-server start
