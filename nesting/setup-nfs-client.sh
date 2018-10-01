#!/bin/bash

DEFAULT_IP="10.10.1.2"
read -p "nfs source ip[$DEFAULT_IP]: " ip
NFS_IP=${ip:-$DEFAULT_IP}

DEFAULT_DIR=/sdc
read -p "nfs source dir[$DEFAULT_DIR]: " dir
NFS_DIR=${dir:-$DEFAULT_DIR}

DEFAULT_DIR=/sdc
read -p "nfs target dir[$DEFAULT_DIR]: " dir
NFS_MOUNT_DIR=${dir:-$DEFAULT_DIR}

mkdir -p $NFS_MOUNT_DIR

sudo apt-get update
sudo apt-get install nfs-common
mount $NFS_IP:$NFS_DIR $NFS_MOUNT_DIR
df -h
