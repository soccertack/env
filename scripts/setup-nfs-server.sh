#!/bin/bash

VM_DIR=/vm
DEFAULT_DIR=/vm
read -p "nfs source dir[$DEFAULT_DIR]: " dir
NFS_DIR=${dir:-$DEFAULT_DIR}
echo $NFS_VER

if [ "$NFS_DIR" == "\sdc" ]; then
	read -p "Want to create file system at $NFS_DIR?[y/n]: " yesno
	if [ $yesno == "y" ]; then
		source mkfs-wisc-sdc.sh
	fi
fi

apt-get update
apt-get -y install nfs-kernel-server
echo "$NFS_DIR *(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
exportfs -a
service nfs-kernel-server start
