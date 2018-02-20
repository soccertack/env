#!/bin/bash

cp /proj/kvmarm-PG0/jintack/nested/v4.15.img.bz2 /vmdata/
pushd /vmdata;pbzip2 -dk v4.15.img.bz2 && mv v4.15.img linaro-trusty.img;popd

mount -o loop /vmdata/linaro-trusty.img /mnt
cat /users/jintackl/.ssh/id_rsa.pub >> /mnt/root/.ssh/authorized_keys
mkdir -p /mnt_l2
mount -o loop /mnt/root/vm/l2.img /mnt_l2
cat /users/jintackl/.ssh/id_rsa.pub >> /mnt_l2/root/.ssh/authorized_keys
umount /mnt_l2
umount /mnt

cp nesting/run.sh /users/jintackl
cp nesting/trap_count.sh /users/jintackl
cp nesting/consume_mem.sh /users/jintackl
cp nesting/kvm_trace.sh /users/jintackl
cp nesting/copy-ssh-key.sh /users/jintackl
cp nesting/pin_vcpus_all.sh /users/jintackl
cp nesting/micro-cycles.py /users/jintackl

