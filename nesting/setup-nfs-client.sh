#!/bin/bash

# $1: source ip
# $2: source dir
# $3: target dir

DEFAULT_IP="10.10.1.1"
NFS_IP=${1:-$DEFAULT_IP}

DEFAULT_DIR=/sdc
NFS_DIR=${2:-$DEFAULT_DIR}

DEFAULT_DIR=/sdc
NFS_MOUNT_DIR=${3:-$DEFAULT_DIR}

mkdir -p $NFS_MOUNT_DIR

dpkg -l | grep -q nfs-common
if [ $? != 0 ]; then
	sudo apt-get update
	sudo apt-get install nfs-common
fi
mount $NFS_IP:$NFS_DIR $NFS_MOUNT_DIR
df -h
