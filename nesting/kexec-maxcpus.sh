#!/bin/sh

read -p "maxcpus=" MAX_CPUS

CMD_LINE=`cat /proc/cmdline`
echo $CMD_LINE
CMD_LINE=`cat /proc/cmdline | sed "s/maxcpus=[0-9]*/maxcpus=$MAX_CPUS/"`
echo $CMD_LINE

#CMD_LINE="$CMD_LINE kvm-intel.nested=1"
#VER=-exits

kexec -l /boot/vmlinuz-4.15.0$VER --initrd=/boot/initrd.img-4.15.0$VER --command-line="$CMD_LINE"

kexec -e
