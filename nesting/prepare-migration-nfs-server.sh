#!/bin/bash

#source mkfs-wisc-sdc.sh
apt-get update
apt-get -y install nfs-kernel-server
echo "/sdb *(rw,sync,no_root_squash,no_subtree_check)" >> /etc/exports
exportfs -a
service nfs-kernel-server start
